# frozen_string_literal: true

require "test_helper"

class RendererTest < Minitest::Test
  def setup
    @icon_data = {
      body: '<path d="M20 6L9 17l-5-5" stroke="currentColor" stroke-width="2"/>',
      width: 24,
      height: 24
    }
  end

  def test_renders_svg
    svg = Kiso::Icons::Renderer.render(@icon_data)
    assert_includes svg, "<svg"
    assert_includes svg, "</svg>"
    assert_includes svg, @icon_data[:body]
  end

  def test_default_attributes
    svg = Kiso::Icons::Renderer.render(@icon_data)
    assert_includes svg, 'xmlns="http://www.w3.org/2000/svg"'
    assert_includes svg, 'viewBox="0 0 24 24"'
    assert_includes svg, 'width="1em"'
    assert_includes svg, 'height="1em"'
    assert_includes svg, 'aria-hidden="true"'
    assert_includes svg, 'fill="none"'
  end

  def test_css_class
    svg = Kiso::Icons::Renderer.render(@icon_data, css_class: "w-5 h-5")
    assert_includes svg, 'class="w-5 h-5"'
  end

  def test_no_class_attribute_when_empty
    svg = Kiso::Icons::Renderer.render(@icon_data, css_class: "")
    refute_includes svg, "class="
  end

  def test_no_class_attribute_when_nil
    svg = Kiso::Icons::Renderer.render(@icon_data)
    refute_includes svg, "class="
  end

  def test_data_attributes
    svg = Kiso::Icons::Renderer.render(@icon_data, data: {icon: "check", test_id: "my-icon"})
    assert_includes svg, 'data-icon="check"'
    assert_includes svg, 'data-test-id="my-icon"'
  end

  def test_aria_label_removes_aria_hidden
    svg = Kiso::Icons::Renderer.render(@icon_data, aria: {label: "Checkmark"})
    assert_includes svg, 'aria-label="Checkmark"'
    assert_includes svg, 'role="img"'
    refute_includes svg, "aria-hidden"
  end

  def test_custom_viewbox
    icon_data = {body: "<circle/>", width: 16, height: 16}
    svg = Kiso::Icons::Renderer.render(icon_data)
    assert_includes svg, 'viewBox="0 0 16 16"'
  end

  def test_escapes_attribute_values
    svg = Kiso::Icons::Renderer.render(@icon_data, aria: {label: 'A "quoted" & <escaped> label'})
    assert_includes svg, "A &quot;quoted&quot; &amp; &lt;escaped&gt; label"
  end

  def test_returns_safe_buffer_when_available
    svg = Kiso::Icons::Renderer.render(@icon_data)
    if defined?(ActiveSupport::SafeBuffer)
      assert_kind_of ActiveSupport::SafeBuffer, svg
    else
      assert_kind_of String, svg
    end
  end
end
