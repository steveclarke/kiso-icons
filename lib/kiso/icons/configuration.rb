# frozen_string_literal: true

require "logger"

module Kiso
  module Icons
    class Configuration
      attr_accessor :default_set, :vendor_path, :fallback_to_api
      attr_writer :logger

      def initialize
        @default_set = "lucide"
        @vendor_path = "vendor/icons"
        @fallback_to_api = defined?(Rails) ? Rails.env.development? : false
      end

      def logger
        @logger ||= Logger.new($stderr, progname: "Kiso::Icons")
      end
    end
  end
end
