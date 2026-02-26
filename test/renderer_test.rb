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
    assert_includes svg, 'stroke="currentColor"'
    assert_includes svg, 'd="M20 6L9 17l-5-5"'
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

  # SVG body sanitization

  def test_strips_script_elements
    icon = {body: '<path d="M0 0"/><script>alert(1)</script>', width: 24, height: 24}
    svg = Kiso::Icons::Renderer.render(icon)
    refute_includes svg, "<script"
    refute_includes svg, "alert"
    assert_includes svg, "<path"
  end

  def test_strips_foreignobject_elements
    icon = {body: '<foreignObject><body xmlns="http://www.w3.org/1999/xhtml"><img src=x onerror="alert(1)"></body></foreignObject>', width: 24, height: 24}
    svg = Kiso::Icons::Renderer.render(icon)
    refute_includes svg, "foreignObject"
    refute_includes svg, "foreignobject"
    refute_includes svg, "onerror"
  end

  def test_strips_iframe_elements
    icon = {body: '<path d="M0 0"/><iframe src="https://evil.com"></iframe>', width: 24, height: 24}
    svg = Kiso::Icons::Renderer.render(icon)
    refute_includes svg, "<iframe"
  end

  def test_strips_event_handler_attributes
    icon = {body: '<rect width="24" height="24" onload="alert(1)" onclick="alert(2)"/>', width: 24, height: 24}
    svg = Kiso::Icons::Renderer.render(icon)
    refute_includes svg, "onload"
    refute_includes svg, "onclick"
    refute_includes svg, "alert"
    assert_includes svg, "<rect"
  end

  def test_strips_javascript_href
    icon = {body: '<a href="javascript:alert(1)"><path d="M0 0"/></a>', width: 24, height: 24}
    svg = Kiso::Icons::Renderer.render(icon)
    refute_includes svg, "javascript:"
    assert_includes svg, "<path"
  end

  def test_preserves_legitimate_svg_body
    body = '<g fill="none"><path d="M5 13l4 4L19 7" stroke="currentColor" stroke-width="2"/></g>'
    icon = {body: body, width: 24, height: 24}
    svg = Kiso::Icons::Renderer.render(icon)
    assert_includes svg, '<g fill="none">'
    assert_includes svg, 'stroke="currentColor"'
    assert_includes svg, 'd="M5 13l4 4L19 7"'
  end

  def test_handles_nil_body
    icon = {body: nil, width: 24, height: 24}
    svg = Kiso::Icons::Renderer.render(icon)
    assert_includes svg, "<svg"
    assert_includes svg, "</svg>"
  end

  def test_handles_empty_body
    icon = {body: "", width: 24, height: 24}
    svg = Kiso::Icons::Renderer.render(icon)
    assert_includes svg, "<svg"
    assert_includes svg, "</svg>"
  end
end
