# frozen_string_literal: true

require "loofah"

module Kiso
  module Icons
    # Produces the final +<svg>+ string from resolved icon data.
    #
    # All SVG body content is sanitized through {SvgScrubber} to strip
    # dangerous elements (+<script>+, +<foreignObject>+, etc.) and event
    # handler attributes before rendering. Attribute values are HTML-escaped.
    #
    # When +ActiveSupport::SafeBuffer+ is available (Rails), the returned
    # string is marked as html_safe so it can be used directly in views.
    class Renderer
      # SVG elements that are stripped during sanitization.
      BLOCKED_SVG_ELEMENTS = %w[
        script foreignobject iframe object embed
      ].freeze

      # Matches attribute names that start with "on" (event handlers).
      EVENT_HANDLER_RE = /\Aon/i

      # Matches +javascript:+ URIs in href attributes.
      JAVASCRIPT_URI_RE = /\A\s*javascript:/i

      class << self
        # Renders icon data as an inline +<svg>+ element.
        #
        # @param icon_data [Hash] icon data with `:body`, `:width`, `:height` keys
        # @param css_class [String, nil] CSS class(es) to add to the +<svg>+ element
        # @param options [Hash] additional HTML attributes. Supports nested
        #   +:data+ and +:aria+ hashes that are expanded into +data-*+ and
        #   +aria-*+ attributes. If +aria: { label: "..." }+ is provided,
        #   +aria-hidden+ is removed and +role="img"+ is added.
        # @return [String, ActiveSupport::SafeBuffer] the rendered SVG markup
        #
        # @example Basic rendering
        #   Renderer.render(icon_data)
        #
        # @example With CSS class and data attributes
        #   Renderer.render(icon_data, css_class: "w-5 h-5", data: { controller: "icon" })
        def render(icon_data, css_class: nil, **options)
          body = sanitize_svg_body(icon_data[:body])
          width = icon_data[:width]
          height = icon_data[:height]

          attrs = {
            "xmlns" => "http://www.w3.org/2000/svg",
            "viewBox" => "0 0 #{width} #{height}",
            "width" => "1em",
            "height" => "1em",
            "aria-hidden" => "true",
            "fill" => "none"
          }

          attrs["class"] = css_class if css_class && !css_class.empty?

          options.each do |key, value|
            if key == :data && value.is_a?(Hash)
              value.each { |k, v| attrs["data-#{k.to_s.tr("_", "-")}"] = v.to_s }
            elsif key == :aria && value.is_a?(Hash)
              value.each { |k, v| attrs["aria-#{k.to_s.tr("_", "-")}"] = v.to_s }
            else
              attrs[key.to_s.tr("_", "-")] = value.to_s
            end
          end

          if attrs.key?("aria-label")
            attrs.delete("aria-hidden")
            attrs["role"] = "img"
          end

          attr_str = attrs.map { |k, v| %(#{k}="#{escape_attr(v)}") }.join(" ")
          svg = %(<svg #{attr_str}>#{body}</svg>)

          if defined?(ActiveSupport::SafeBuffer)
            ActiveSupport::SafeBuffer.new(svg)
          else
            svg
          end
        end

        private

        # Sanitizes SVG body content by running it through {SvgScrubber}.
        #
        # @param body [String, nil] raw SVG body markup
        # @return [String] sanitized SVG body
        def sanitize_svg_body(body)
          return "" if body.nil? || body.empty?

          Loofah.scrub_fragment(body, SVG_SCRUBBER).to_s
        end

        # HTML-escapes an attribute value to prevent injection.
        #
        # @param value [String] the raw attribute value
        # @return [String] the escaped value
        def escape_attr(value)
          value.to_s
            .gsub("&", "&amp;")
            .gsub('"', "&quot;")
            .gsub("<", "&lt;")
            .gsub(">", "&gt;")
        end
      end

      # Loofah scrubber that strips dangerous elements and event handlers
      # from SVG body content while preserving legitimate SVG markup.
      #
      # Processes nodes top-down, removing {BLOCKED_SVG_ELEMENTS} entirely
      # and stripping +on*+ event handler attributes and +javascript:+ URIs
      # from remaining elements.
      class SvgScrubber < Loofah::Scrubber
        # Initializes the scrubber with top-down traversal direction.
        def initialize
          @direction = :top_down
        end

        # Processes a single DOM node during sanitization.
        #
        # @param node [Nokogiri::XML::Node] the node to inspect
        # @return [Symbol] +CONTINUE+ or +STOP+ to control traversal
        def scrub(node)
          return CONTINUE if node.text? || node.cdata?

          if BLOCKED_SVG_ELEMENTS.include?(node.name.downcase)
            node.remove
            return STOP
          end

          node.attribute_nodes.each do |attr|
            if attr.name.match?(EVENT_HANDLER_RE)
              attr.remove
            elsif attr.name.casecmp("href").zero? || attr.name == "xlink:href"
              attr.remove if attr.value.match?(JAVASCRIPT_URI_RE)
            end
          end

          CONTINUE
        end
      end

      # Frozen singleton scrubber instance used by {.sanitize_svg_body}.
      # @!visibility private
      SVG_SCRUBBER = SvgScrubber.new.freeze
    end
  end
end
