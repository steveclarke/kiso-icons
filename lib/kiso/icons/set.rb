# frozen_string_literal: true

require "json"
require "zlib"
require "stringio"
require "pathname"

module Kiso
  module Icons
    # Represents a parsed Iconify icon set.
    #
    # An Iconify JSON file contains a flat map of icon bodies, optional aliases
    # (which reference a parent icon and may apply transforms like rotate/flip),
    # and set-level defaults for width/height.
    #
    # Sets are loaded from two sources:
    # - **Vendored** JSON files on disk ({.from_vendor})
    # - **Bundled** gzip files shipped inside the gem ({.from_bundled})
    #
    # @see https://iconify.design/docs/types/iconify-json.html Iconify JSON format
    class Set
      # @!attribute [r] prefix
      #   @return [String] the icon set prefix (e.g. +"lucide"+, +"mdi"+)

      # @!attribute [r] default_width
      #   @return [Integer] default SVG width for icons in this set

      # @!attribute [r] default_height
      #   @return [Integer] default SVG height for icons in this set

      attr_reader :prefix, :default_width, :default_height

      # Initializes a new Set from parsed Iconify JSON data.
      #
      # @param prefix [String] the icon set prefix
      # @param data [Hash] parsed Iconify JSON with +"icons"+, +"aliases"+,
      #   +"width"+, +"height"+, and +"info"+ keys
      def initialize(prefix:, data:)
        @prefix = prefix
        @icons = data["icons"] || {}
        @aliases = data["aliases"] || {}
        @default_width = data["width"] || 24
        @default_height = data["height"] || 24
        @info = data["info"] || {}
      end

      # Looks up an icon by name, resolving aliases and applying transforms.
      #
      # @param name [String] the icon name (e.g. +"check"+)
      # @return [Hash, nil] icon data with `:body`, `:width`, `:height` keys,
      #   or nil if not found
      def icon(name)
        if (icon_data = @icons[name])
          return build_icon_data(icon_data)
        end

        resolved_name = resolve_alias(name)
        if resolved_name && (icon_data = @icons[resolved_name])
          alias_data = @aliases[name]
          return build_icon_data(icon_data, alias_transforms: alias_data)
        end

        nil
      end

      # Returns all icon names including aliases.
      #
      # @return [Array<String>]
      def icon_names
        @icons.keys + @aliases.keys
      end

      # Returns the number of concrete (non-alias) icons in the set.
      #
      # @return [Integer]
      def icon_count
        @icons.size
      end

      # Returns the human-readable display name from the set's metadata,
      # falling back to the prefix.
      #
      # @return [String]
      def display_name
        @info["name"] || @prefix
      end

      class << self
        # Loads an icon set from a vendored JSON file on disk.
        #
        # @param prefix [String] the icon set prefix
        # @return [Set, nil] the parsed set, or nil if the file doesn't exist
        def from_vendor(prefix)
          path = vendor_path_for(prefix)
          return nil unless File.exist?(path)

          data = JSON.parse(File.read(path))
          new(prefix: prefix, data: data)
        end

        # Loads an icon set from a bundled gzip file inside the gem.
        #
        # Decompresses entirely in memory — reads raw bytes with
        # +File.binread+, wraps in a +StringIO+ for +Zlib::GzipReader+,
        # and parses the resulting JSON directly. No temp files are written.
        #
        # @param prefix [String] the icon set prefix
        # @return [Set, nil] the parsed set, or nil if the file doesn't exist
        def from_bundled(prefix)
          path = bundled_path_for(prefix)
          return nil unless File.exist?(path)

          gz_data = File.binread(path)
          json_str = Zlib::GzipReader.new(StringIO.new(gz_data)).read
          data = JSON.parse(json_str)
          new(prefix: prefix, data: data)
        end

        # Returns the absolute path for a vendored JSON file.
        #
        # @param prefix [String] the icon set prefix
        # @return [String] absolute file path
        def vendor_path_for(prefix)
          base = if defined?(Rails) && Rails.root
            Rails.root
          else
            Pathname.new(Dir.pwd)
          end
          base.join(Kiso::Icons.configuration.vendor_path, "#{prefix}.json").to_s
        end

        # Returns the absolute path for a bundled gzip file.
        #
        # @param prefix [String] the icon set prefix
        # @return [String] absolute file path
        def bundled_path_for(prefix)
          File.join(gem_data_path, "#{prefix}.json.gz")
        end

        # Returns the absolute path to the gem's +data/+ directory.
        #
        # @return [String]
        def gem_data_path
          File.expand_path("../../../../data", __FILE__)
        end

        # Returns the prefixes of all vendored icon sets found on disk.
        #
        # @return [Array<String>] sorted list of set prefixes
        def vendored_sets
          pattern = if defined?(Rails) && Rails.root
            Rails.root.join(Kiso::Icons.configuration.vendor_path, "*.json").to_s
          else
            File.join(Dir.pwd, Kiso::Icons.configuration.vendor_path, "*.json")
          end

          Dir.glob(pattern).map { |f| File.basename(f, ".json") }.sort
        end
      end

      private

      # Recursively resolves an alias to its root icon name.
      # Guards against infinite loops with a depth limit of 5.
      #
      # @param name [String] the alias name to resolve
      # @param depth [Integer] current recursion depth
      # @return [String, nil] the resolved icon name, or nil
      def resolve_alias(name, depth: 0)
        return nil if depth > 5
        alias_entry = @aliases[name]
        return nil unless alias_entry

        parent = alias_entry["parent"]
        return parent if @icons.key?(parent)

        resolve_alias(parent, depth: depth + 1)
      end

      # Builds the icon data hash, optionally applying alias transforms.
      #
      # @param icon_data [Hash] raw icon entry from the Iconify JSON
      # @param alias_transforms [Hash, nil] alias entry with optional
      #   +"rotate"+, +"hFlip"+, +"vFlip"+, +"width"+, +"height"+ keys
      # @return [Hash] icon data with `:body`, `:width`, `:height` keys
      def build_icon_data(icon_data, alias_transforms: nil)
        body = icon_data["body"]
        width = icon_data["width"] || @default_width
        height = icon_data["height"] || @default_height

        if alias_transforms
          body = apply_transforms(body, alias_transforms, width, height)
          width = alias_transforms["width"] || width
          height = alias_transforms["height"] || height
        end

        {body: body, width: width, height: height}
      end

      # Wraps the SVG body in a +<g transform="...">+ element to apply
      # rotation and/or flip transforms from an alias definition.
      #
      # @param body [String] the raw SVG body markup
      # @param transforms [Hash] transform data with +"rotate"+, +"hFlip"+,
      #   +"vFlip"+ keys
      # @param width [Integer] the icon width (for computing transform origins)
      # @param height [Integer] the icon height (for computing transform origins)
      # @return [String] the transformed SVG body
      def apply_transforms(body, transforms, width, height)
        parts = []

        if transforms["rotate"]
          degrees = transforms["rotate"] * 90
          parts << "rotate(#{degrees} #{width / 2.0} #{height / 2.0})"
        end

        scale_x = transforms["hFlip"] ? -1 : 1
        scale_y = transforms["vFlip"] ? -1 : 1

        if scale_x != 1 || scale_y != 1
          tx = transforms["hFlip"] ? width : 0
          ty = transforms["vFlip"] ? height : 0
          parts << "translate(#{tx} #{ty})" if tx != 0 || ty != 0
          parts << "scale(#{scale_x} #{scale_y})"
        end

        if parts.any?
          %(<g transform="#{parts.join(" ")}">#{body}</g>)
        else
          body
        end
      end
    end
  end
end
