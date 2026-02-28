# frozen_string_literal: true

# Root namespace for the kiso-icons gem.
module Kiso
  # Top-level namespace for the kiso-icons gem.
  #
  # Provides inline SVG rendering of Iconify icon sets in Rails applications.
  # Icons can be vendored from any of Iconify's 224 sets (299k+ icons) or
  # loaded from the bundled Lucide set that ships with the gem.
  #
  # @example Configure the gem
  #   Kiso::Icons.configure do |config|
  #     config.default_set = "heroicons"
  #     config.vendor_path = "vendor/icons"
  #   end
  #
  # @example Resolve an icon
  #   icon_data = Kiso::Icons.resolve("lucide:check")
  #
  # @see Kiso::Icons::Configuration
  # @see Kiso::Icons::Resolver
  module Icons
    # Base error class for all kiso-icons errors.
    class Error < StandardError; end

    # Raised when a requested icon cannot be found in any loaded set.
    class IconNotFound < Error; end

    # Raised when a requested icon set cannot be found.
    class SetNotFound < Error; end

    class << self
      # Returns the global configuration instance.
      #
      # @return [Configuration] the current configuration
      def configuration
        @configuration ||= Configuration.new
      end

      # Yields the global configuration for modification.
      #
      # @yieldparam config [Configuration] the configuration instance
      # @return [void]
      def configure
        yield(configuration)
      end

      # Returns the global resolver instance.
      #
      # @return [Resolver] the current resolver
      def resolver
        @resolver ||= Resolver.new
      end

      # Returns the configured logger.
      #
      # @return [Logger] the logger instance
      def logger
        configuration.logger
      end

      # Returns the global cache instance.
      #
      # @return [Cache] the current cache
      def cache
        @cache ||= Cache.new
      end

      # Resolves an icon by name, delegating to the {Resolver}.
      #
      # @param name [String] icon name, optionally prefixed with set
      #   (e.g. "check" or "lucide:check")
      # @return [Hash, nil] icon data hash with `:body`, `:width`, `:height`
      #   keys, or nil if not found
      def resolve(name)
        resolver.resolve(name)
      end

      # Resets all singletons (configuration, resolver, cache).
      # Primarily used in tests to ensure a clean state.
      #
      # @return [void]
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
require "kiso/icons/railtie" if defined?(Rails::Railtie)
