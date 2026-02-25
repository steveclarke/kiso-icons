# frozen_string_literal: true

module Kiso
  module Icons
    class Configuration
      attr_accessor :default_set, :vendor_path, :fallback_to_api

      def initialize
        @default_set = "lucide"
        @vendor_path = "vendor/icons"
        @fallback_to_api = defined?(Rails) ? Rails.env.development? : false
      end
    end
  end
end
