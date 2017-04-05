# frozen_string_literal: true

require_relative "scanner"

module CC
  module Engine
    class Grep
      def initialize(root:, config: {}, io: $stdout)
        @root = root
        @config = config
        @io = io
      end

      def run
        Dir.chdir(root) do
          scan
        end
      end

      private

      attr_reader :root, :config, :io

      def patterns
        config.fetch("config").fetch("patterns")
      end

      def include_paths
        config.dig("include_paths") || ["."]
      end

      def all_paths
        @all_paths ||= Dir[*include_paths.map { |g| g.gsub(%r{/\z}, "/**/*") }].sort
      end

      def scan
        patterns.each do |check_name, check_config|
          Scanner.new(
            check_name: check_name,
            config: check_config,
            paths: all_paths,
            io: io,
          ).run
        end
      rescue ScannerConfig::InvalidConfigError => e
        $stderr.puts e.message
        exit 1
      rescue => e
        $stderr.puts e.message
      end
    end
  end
end
