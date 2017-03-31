# frozen_string_literal: true

module CC
  module Engine
    class ScannerConfig
      CATEGORIES = [
        "Bug Risk", "Clarity", "Compatibility", "Complexity", "Duplication",
        "Performance", "Security", "Style"
      ].freeze
      SEVERITIES = %w[info minor major critical blocker].freeze

      class InvalidConfigError < StandardError; end

      def initialize(config, check_name)
        @config = config
        @check_name = check_name

        validate_config!
      end

      def pattern
        config.fetch("pattern")
      end

      def severity
        config.fetch("severity", "minor")
      end

      def description
        config.fetch("annotation")
      end

      def categories
        Array(config.fetch("categories", "Bug Risk"))
      end

      def path_patterns
        Array(config.fetch("path_patterns", ["**/*"]))
      end

      def content
        config["content"]
      end

      private

      attr_reader :config, :check_name

      def validate_config!
        validate_required_config_entries!
        validate_severity!
        validate_categories!
      end

      def validate_required_config_entries!
        unless config.key?("pattern")
          raise InvalidConfigError, "Pattern is missing from #{check_name}"
        end
        if !config.key?("annotation") || config["annotation"].strip.empty?
          raise InvalidConfigError, "Annotation is missing from #{check_name}"
        end
      end

      def validate_severity!
        unless SEVERITIES.include? severity
          raise InvalidConfigError, %(Invalid severity "#{severity}" for #{check_name}. Must be one of the following: #{SEVERITIES.join ", "})
        end
      end

      def validate_categories!
        categories.each do |category|
          unless CATEGORIES.include? category
            raise InvalidConfigError, %(Invalid category "#{category}" for #{check_name}. Must be one of the following: #{CATEGORIES.join ", "})
          end
        end
      end
    end
  end
end
