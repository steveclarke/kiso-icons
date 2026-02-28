# frozen_string_literal: true

require "logger"

module Kiso
  module Icons
    # Holds gem-wide configuration values.
    #
    # Access via {Kiso::Icons.configure}:
    #
    # @example
    #   Kiso::Icons.configure do |config|
    #     config.default_set = "heroicons"
    #     config.vendor_path = "vendor/icons"
    #   end
    class Configuration
      # @!attribute [rw] default_set
      #   The icon set prefix used when no prefix is provided in the icon name.
      #   @return [String] defaults to +"lucide"+

      # @!attribute [rw] vendor_path
      #   Relative path (from Rails root or cwd) where vendored JSON files are stored.
      #   @return [String] defaults to +"vendor/icons"+

      # @!attribute [w] logger
      #   Sets the logger instance used for warnings and debug output.
      #   @return [Logger]

      attr_accessor :default_set, :vendor_path
      attr_writer :logger

      # Initializes a new Configuration with default values.
      def initialize
        @default_set = "lucide"
        @vendor_path = "vendor/icons"
      end

      # Returns the logger, initializing a stderr logger if none has been set.
      #
      # @return [Logger]
      def logger
        @logger ||= Logger.new($stderr, progname: "Kiso::Icons")
      end
    end
  end
end
