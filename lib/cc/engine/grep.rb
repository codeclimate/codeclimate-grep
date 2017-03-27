# frozen_string_literal: true

require "json"
require "open3"

module CC
  module Engine
    class Grep
      MATCH_START = "\e[01;31m\e[K"
      MATCH_END = "\e[m\e[K"
      MARKER_RE = /\e\[.*?\e\[K/
      MATCH_RE = /#{Regexp.escape MATCH_START}(?<str>.*?)#{Regexp.escape MATCH_END}/

      def initialize(root:, config: {}, io: $stdout)
        @root = root
        @config = config
        @io = io
      end

      def run
        Dir.chdir(root) do
          Open3.popen2(*grep_command) do |_in, out, _wait_thread|
            out.each do |line|
              report line
            end
          end
        end
      end

      private

      attr_reader :root, :config, :io

      def patterns
        config.dig("config", "patterns") || []
      end

      def include_paths
        config.dig("include_paths") || ["."]
      end

      def message
        config.dig("config", "output") || ""
      end

      def pattern_args
        ["-e"].product(patterns).flatten
      end

      def grep_command
        [
          "grep",
          "--color=always", # Highlight matches
          "--extended-regexp",
          "--with-filename", "--line-number",
          "--recursive", "--binary-files=without-match",
          "--no-messages",
          *pattern_args,
          *include_paths
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
        JSON.generate(
          type: "issue",
          check_name: "Pattern Match",
          description: message,
          categories: ["Bug Risk"],
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
          severity: "info",
        )
      end
    end
  end
end
