# frozen_string_literal: true

require "integration_test_helper"

class HelperIntegrationTest < ActionDispatch::IntegrationTest
  def test_renders_icon_in_view
    get "/icons/show"

    assert_response :success
    assert_includes response.body, "<svg"
    assert_includes response.body, 'width="1em"'
    assert_includes response.body, 'height="1em"'
    assert_includes response.body, 'aria-hidden="true"'
  end

  def test_kiso_icon_tag_in_view_context
    view = ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)

    svg = view.kiso_icon_tag("lucide:check")

    assert_kind_of ActiveSupport::SafeBuffer, svg
    assert_includes svg, "<svg"
    assert_includes svg, "</svg>"
  end

  def test_kiso_icon_tag_with_class
    view = ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)

    svg = view.kiso_icon_tag("lucide:check", class: "w-5 h-5")

    assert_includes svg, 'class="w-5 h-5"'
  end

  def test_kiso_icon_tag_with_aria_label
    view = ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)

    svg = view.kiso_icon_tag("lucide:check", aria: {label: "Done"})

    assert_includes svg, 'aria-label="Done"'
    assert_includes svg, 'role="img"'
    refute_includes svg, "aria-hidden"
  end

  def test_missing_icon_returns_empty_string
    view = ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)

    result = view.kiso_icon_tag("nonexistent:missing")

    assert_equal "", result
  end
end
