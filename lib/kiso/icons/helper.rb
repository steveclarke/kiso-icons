# frozen_string_literal: true

require "erb"

module Kiso
  module Icons
    # Rails view helper providing the {#kiso_icon_tag} method.
    #
    # Included into +ActionView::Base+ automatically by {Railtie}.
    module Helper
      # Renders an inline SVG icon from an Iconify icon set.
      #
      # In development, returns an HTML comment when the icon is not found.
      # In production, returns an empty string.
      #
      # @param name [String] icon name, optionally prefixed with set
      #   (e.g. +"check"+ or +"lucide:check"+)
      # @param options [Hash] HTML attributes forwarded to {Renderer.render}.
      #   Use +:class+ for CSS classes, +:data+ / +:aria+ hashes for
      #   data-* and aria-* attributes.
      # @return [ActiveSupport::SafeBuffer, String] the rendered SVG markup
      #
      # @example Basic usage
      #   kiso_icon_tag("lucide:check")
      #
      # @example With default set (lucide)
      #   kiso_icon_tag("check")
      #
      # @example With CSS classes
      #   kiso_icon_tag("check", class: "w-5 h-5")
      #
      # @example Accessible icon with label
      #   kiso_icon_tag("check", aria: { label: "Done" })
      def kiso_icon_tag(name, **options)
        icon_data = Kiso::Icons.resolve(name.to_s)

        unless icon_data
          if defined?(Rails) && Rails.env.development?
            return safe_string("<!-- kiso-icons: '#{ERB::Util.html_escape(name)}' not found -->")
          end
          return safe_string("")
        end

        Kiso::Icons::Renderer.render(icon_data, css_class: options.delete(:class), **options)
      end

      private

      # Wraps a string in +ActiveSupport::SafeBuffer+ when available,
      # otherwise returns the string as-is.
      #
      # @param str [String] the string to mark as html_safe
      # @return [ActiveSupport::SafeBuffer, String]
      def safe_string(str)
        if defined?(ActiveSupport::SafeBuffer)
          ActiveSupport::SafeBuffer.new(str)
        else
          str
        end
      end
    end
  end
end
