# frozen_string_literal: true

require "loofah"

module Kiso
  module Icons
    class Renderer
      BLOCKED_SVG_ELEMENTS = %w[
        script foreignobject iframe object embed
      ].freeze

      EVENT_HANDLER_RE = /\Aon/i
      JAVASCRIPT_URI_RE = /\A\s*javascript:/i

      class << self
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

        def sanitize_svg_body(body)
          return "" if body.nil? || body.empty?

          Loofah.scrub_fragment(body, SVG_SCRUBBER).to_s
        end

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
      class SvgScrubber < Loofah::Scrubber
        def initialize
          @direction = :top_down
        end

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

      SVG_SCRUBBER = SvgScrubber.new.freeze
    end
  end
end
