# frozen_string_literal: true

require "integration_test_helper"

class RailtieTest < Minitest::Test
  def test_helper_included_in_action_view
    assert_includes ActionView::Base.instance_methods, :kiso_icon_tag
  end
end
