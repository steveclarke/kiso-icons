# frozen_string_literal: true

require_relative "boot"

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "kiso/icons"

module Dummy
  class Application < Rails::Application
    config.load_defaults 8.0
    config.eager_load = false
    config.secret_key_base = "test-secret-key-base-for-kiso-icons-dummy"
    config.hosts.clear
  end
end
