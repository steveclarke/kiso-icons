# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    Kiso::Icons.reset!
  end

  def teardown
    Kiso::Icons.reset!
  end

  def test_default_set
    assert_equal "lucide", Kiso::Icons.configuration.default_set
  end

  def test_default_vendor_path
    assert_equal "vendor/icons", Kiso::Icons.configuration.vendor_path
  end

  def test_configure_block
    Kiso::Icons.configure do |config|
      config.default_set = "heroicons"
      config.vendor_path = "custom/path"
    end

    assert_equal "heroicons", Kiso::Icons.configuration.default_set
    assert_equal "custom/path", Kiso::Icons.configuration.vendor_path
  end

  def test_reset_restores_defaults
    Kiso::Icons.configure { |c| c.default_set = "mdi" }
    Kiso::Icons.reset!
    assert_equal "lucide", Kiso::Icons.configuration.default_set
  end
end
