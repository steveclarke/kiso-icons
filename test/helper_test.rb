# frozen_string_literal: true

require "test_helper"
require "kiso/icons/helper"

class HelperTest < Minitest::Test
  include Kiso::Icons::Helper

  def setup
    Kiso::Icons.reset!
  end

  def teardown
    Kiso::Icons.reset!
  end

  def test_renders_icon_by_prefixed_name
    svg = kiso_icon_tag("lucide:check")
    assert_includes svg, "<svg"
    assert_includes svg, "</svg>"
    assert_includes svg, 'width="1em"'
    assert_includes svg, 'height="1em"'
  end

  def test_renders_icon_by_bare_name
    svg = kiso_icon_tag("check")
    assert_includes svg, "<svg"
  end

  def test_passes_class_through
    svg = kiso_icon_tag("lucide:check", class: "w-5 h-5")
    assert_includes svg, 'class="w-5 h-5"'
  end

  def test_passes_aria_attributes
    svg = kiso_icon_tag("lucide:check", aria: {label: "Done"})
    assert_includes svg, 'aria-label="Done"'
    assert_includes svg, 'role="img"'
    refute_includes svg, "aria-hidden"
  end

  def test_passes_data_attributes
    svg = kiso_icon_tag("lucide:check", data: {icon: "check"})
    assert_includes svg, 'data-icon="check"'
  end

  def test_returns_empty_string_for_missing_icon
    result = kiso_icon_tag("nonexistent:missing")
    assert_equal "", result
  end

  def test_no_tailwind_classes_in_output
    svg = kiso_icon_tag("lucide:check")
    refute_includes svg, "shrink-0"
    refute_includes svg, "size-"
  end
end
