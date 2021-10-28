# frozen_string_literal: true

module CC
  module Engine
    class ScannerConfig
      CATEGORIES = [
        "Bug Risk", "Clarity", "Compatibility", "Complexity", "Duplication",
        "Performance", "Security", "Style"
      ].freeze
      SEVERITIES = %w[info minor major critical blocker].freeze

      REGEXP_OPTIONS = {
        "fixed" => "--fixed-strings",
        "basic" => "--basic-regexp",
        "extended" => "--extended-regexp",
        "perl" => "--perl-regexp",
      }

      DEFAULT_REGEXP = "extended"

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

      def regexp_option
        regexp = config.fetch("regexp", DEFAULT_REGEXP)

        REGEXP_OPTIONS.fetch(regexp) do
          raise InvalidConfigError, %(Invalid regexp "#{regexp}" for #{check_name}. Must be one of the following: #{REGEXP_OPTIONS.keys.join ", "})
        end
      end

      private

      attr_reader :config, :check_name

      def validate_config!
        validate_required_config_entries!
        validate_severity!
        validate_categories!
        validate_regexp!
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

      def validate_regexp!
        # Option access validates, so just call eagerly
        regexp_option
      end
    end
  end
end
