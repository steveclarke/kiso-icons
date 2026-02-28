# frozen_string_literal: true

module Kiso
  module Icons
    # Central orchestrator for icon resolution.
    #
    # Follows a resolution cascade to find icon data:
    #
    # 1. **In-memory cache** — instant return for previously resolved icons
    # 2. **Already-loaded set** — set parsed earlier in this process
    # 3. **Vendored JSON** — full set files committed under +vendor/icons/+
    # 4. **Bundled gzip** — Lucide set shipped inside the gem
    #
    # Once a {Set} is loaded it is kept in +@loaded_sets+ so the JSON is
    # only parsed once per process. Individual icon lookups are cached in
    # {Cache} for even faster repeat access.
    class Resolver
      # Initializes a new Resolver with an empty set of loaded icon sets.
      def initialize
        @loaded_sets = {}
        @mutex = Mutex.new
      end

      # Resolves an icon by name through the resolution cascade.
      #
      # @param name [String] icon name, optionally prefixed with set
      #   (e.g. +"check"+ or +"lucide:check"+)
      # @return [Hash, nil] icon data hash with `:body`, `:width`, `:height`
      #   keys, or nil if not found
      def resolve(name)
        set_prefix, icon_name = parse_name(name)

        # 1. In-memory cache
        cached = Kiso::Icons.cache.get(set_prefix, icon_name)
        return cached if cached

        # 2. Already-loaded set
        icon_data = resolve_from_loaded_set(set_prefix, icon_name)

        # 3. Vendored JSON
        icon_data ||= resolve_from_vendor(set_prefix, icon_name)

        # 4. Bundled (lucide ships in gem)
        icon_data ||= resolve_from_bundled(set_prefix, icon_name)

        Kiso::Icons.cache.set(set_prefix, icon_name, icon_data) if icon_data

        icon_data
      end

      # Clears all loaded icon sets, forcing them to be re-parsed on next access.
      #
      # @return [void]
      def clear!
        @mutex.synchronize { @loaded_sets.clear }
      end

      private

      # Parses an icon name into set prefix and icon name components.
      # If no prefix is given, uses the configured default set.
      #
      # @param name [String] raw icon name
      # @return [Array<String>] two-element array of +[set_prefix, icon_name]+
      def parse_name(name)
        name = name.to_s.strip
        if name.include?(":")
          name.split(":", 2)
        else
          [Kiso::Icons.configuration.default_set, name]
        end
      end

      # Looks up the icon in a set that has already been parsed and loaded.
      #
      # @param set_prefix [String] the icon set prefix
      # @param icon_name [String] the icon name
      # @return [Hash, nil] icon data or nil
      def resolve_from_loaded_set(set_prefix, icon_name)
        set = @mutex.synchronize { @loaded_sets[set_prefix] }
        set&.icon(icon_name)
      end

      # Attempts to load the icon set from vendored JSON on disk.
      #
      # @param set_prefix [String] the icon set prefix
      # @param icon_name [String] the icon name
      # @return [Hash, nil] icon data or nil
      def resolve_from_vendor(set_prefix, icon_name)
        set = Set.from_vendor(set_prefix)
        return nil unless set

        @mutex.synchronize { @loaded_sets[set_prefix] = set }
        set.icon(icon_name)
      end

      # Attempts to load the icon set from a bundled gzip file inside the gem.
      #
      # @param set_prefix [String] the icon set prefix
      # @param icon_name [String] the icon name
      # @return [Hash, nil] icon data or nil
      def resolve_from_bundled(set_prefix, icon_name)
        set = Set.from_bundled(set_prefix)
        return nil unless set

        @mutex.synchronize { @loaded_sets[set_prefix] = set }
        set.icon(icon_name)
      end
    end
  end
end
