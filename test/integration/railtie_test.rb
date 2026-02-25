# frozen_string_literal: true

require "integration_test_helper"

class RailtieTest < Minitest::Test
  def test_helper_included_in_action_view
    assert_includes ActionView::Base.instance_methods, :kiso_icon_tag
  end

  def test_configures_fallback_to_api_in_test
    assert Kiso::Icons.configuration.fallback_to_api,
      "Expected fallback_to_api to be true in test environment"
  end
end
