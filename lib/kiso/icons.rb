# frozen_string_literal: true

module Kiso
  module Icons
    class Error < StandardError; end
    class IconNotFound < Error; end
    class SetNotFound < Error; end

    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end

      def resolver
        @resolver ||= Resolver.new
      end

      def logger
        configuration.logger
      end

      def cache
        @cache ||= Cache.new
      end

      def resolve(name)
        resolver.resolve(name)
      end

      def reset!
        @resolver = nil
        @cache = nil
        @configuration = nil
      end
    end
  end
end

require "kiso/icons/version"
require "kiso/icons/configuration"
require "kiso/icons/cache"
require "kiso/icons/set"
require "kiso/icons/resolver"
require "kiso/icons/renderer"
require "kiso/icons/api_client"
require "kiso/icons/railtie" if defined?(Rails::Railtie)
