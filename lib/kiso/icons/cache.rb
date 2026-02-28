# frozen_string_literal: true

module Kiso
  module Icons
    # Thread-safe in-memory cache for resolved icon data.
    #
    # Keyed by +"set_prefix:icon_name"+. All reads and writes are
    # protected by a Mutex so the cache is safe to share across threads
    # (e.g. in Puma).
    class Cache
      # Initializes an empty cache with a new Mutex.
      def initialize
        @store = {}
        @mutex = Mutex.new
      end

      # Retrieves cached icon data.
      #
      # @param set_prefix [String] the icon set prefix (e.g. +"lucide"+)
      # @param name [String] the icon name (e.g. +"check"+)
      # @return [Hash, nil] the cached icon data, or nil if not present
      def get(set_prefix, name)
        @mutex.synchronize { @store["#{set_prefix}:#{name}"] }
      end

      # Stores icon data in the cache. The data is frozen before storage.
      #
      # @param set_prefix [String] the icon set prefix
      # @param name [String] the icon name
      # @param data [Hash] icon data hash (`:body`, `:width`, `:height`)
      # @return [Hash] the frozen icon data
      def set(set_prefix, name, data)
        @mutex.synchronize { @store["#{set_prefix}:#{name}"] = data.freeze }
      end

      # Removes all entries from the cache.
      #
      # @return [void]
      def clear!
        @mutex.synchronize { @store.clear }
      end

      # Returns the number of cached icon entries.
      #
      # @return [Integer]
      def size
        @mutex.synchronize { @store.size }
      end
    end
  end
end
