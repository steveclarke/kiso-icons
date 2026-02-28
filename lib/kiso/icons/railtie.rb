# frozen_string_literal: true

require "kiso/icons/helper"

module Kiso
  module Icons
    # Rails integration for kiso-icons.
    #
    # Automatically loaded when +Rails::Railtie+ is defined.
    # Registers three initializers:
    #
    # - **kiso_icons.configure** — sets the logger to +Rails.logger+
    # - **kiso_icons.helpers** — includes {Helper} into +ActionView::Base+
    #   so +kiso_icon_tag+ is available in all views
    # - **rake_tasks** — loads the kiso-icons rake tasks
    class Railtie < ::Rails::Railtie
      initializer "kiso_icons.configure" do |_app|
        Kiso::Icons.configure do |config|
          config.logger = Rails.logger
        end
      end

      initializer "kiso_icons.helpers" do
        ActiveSupport.on_load(:action_view) do
          include Kiso::Icons::Helper
        end
      end

      rake_tasks do
        load "tasks/kiso_icons_tasks.rake"
      end
    end
  end
end
