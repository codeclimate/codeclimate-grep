# frozen_string_literal: true

require "json"
require "open3"
require_relative "scanner_config"

module CC
  module Engine
    class Scanner
      MATCH_START = "\e[01;31m\e[K"
      MATCH_END = "\e[m\e[K"
      MARKER_RE = /\e\[.*?\e\[K/
      MATCH_RE = /#{Regexp.escape MATCH_START}(?<str>.*?)#{Regexp.escape MATCH_END}/

      def initialize(check_name:, config:, paths: [], io: $stdout)
        @check_name = check_name
        @config = ScannerConfig.new(config, check_name)
        @paths = paths
        @io = io
      end

      def run
        qualifying_paths.each do |path|
          Open3.popen2(*(grep_command path)) do |_in, out, _wait_thread|
            out.each do |line|
              report line
            end
          end
        end
      end

      private

      attr_reader :check_name, :paths, :config, :io

      def qualifying_paths
        paths & Dir[*config.path_patterns]
      end

      def grep_command(path)
        [
          "grep",
          config.regexp_option,
          "--color=always", # Highlight matches
          "--with-filename", "--line-number",
          "--binary-files=without-match",
          "--no-messages",
          "-e", config.pattern,
          path
        ]
      end

      def all_matches(string)
        [].tap do |matches|
          match = MATCH_RE.match(string)
          while match
            matches << match
            match = MATCH_RE.match(string, matches.last.end(0))
          end
        end
      end

      def report(match_line)
        filename, line, string = match_line.split(":", 3)
        filename = filename.gsub(MARKER_RE, "")
        line = line.gsub(MARKER_RE, "").to_i
        string = string.sub(/^#{MARKER_RE}/, "")

        all_matches(string).each do |match|
          real_begin = string[0..match.begin(0)].gsub(MARKER_RE, "").length
          real_end = real_begin + match[:str].length
          io.print "#{report_json filename, line, real_begin, real_end}\n\0"
        end
      end

      def report_json(filename, line, real_begin, real_end) # rubocop: disable Metrics/MethodLength
        data = {
          type: "issue",
          check_name: check_name,
          description: config.description,
          categories: config.categories,
          location: {
            path: filename,
            positions: {
              begin: {
                line: line,
                column: real_begin,
              },
              end: {
                line: line,
                column: real_end,
              },
            },
          },
          severity: config.severity,
        }
        if config.content
          data["content"] = { body: config.content }
        end
        JSON.generate(data)
      end
    end
  end
end
