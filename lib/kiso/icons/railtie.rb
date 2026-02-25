# frozen_string_literal: true

require "kiso/icons/helper"

module Kiso
  module Icons
    class Railtie < ::Rails::Railtie
      initializer "kiso_icons.configure" do |_app|
        Kiso::Icons.configure do |config|
          config.fallback_to_api = Rails.env.development? || Rails.env.test?
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
