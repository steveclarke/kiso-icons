# frozen_string_literal: true

require "erb"

module Kiso
  module Icons
    module Helper
      # Renders an inline SVG icon from Iconify icon sets.
      #
      #   kiso_icon_tag("lucide:check")
      #   kiso_icon_tag("check")                          # uses default set (lucide)
      #   kiso_icon_tag("check", class: "w-5 h-5")       # pass any CSS classes
      #   kiso_icon_tag("check", aria: { label: "Done" }) # accessible icon
      #
      def kiso_icon_tag(name, **options)
        icon_data = Kiso::Icons.resolve(name.to_s)

        unless icon_data
          if defined?(Rails) && Rails.env.development?
            return "<!-- kiso-icons: '#{ERB::Util.html_escape(name)}' not found -->".html_safe
          end
          return "".html_safe
        end

        Kiso::Icons::Renderer.render(icon_data, css_class: options.delete(:class), **options)
      end
    end
  end
end
