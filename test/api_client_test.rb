# frozen_string_literal: true

require "test_helper"

class ApiClientTest < Minitest::Test
  def setup
    WebMock.enable!
  end

  def teardown
    WebMock.reset!
  end

  def test_constructs_correct_url
    stub = stub_request(:get, "https://api.iconify.design/lucide.json?icons=check")
      .to_return(
        status: 200,
        body: iconify_response("check", body: "<path/>").to_json,
        headers: {"Content-Type" => "application/json"}
      )

    Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_requested(stub)
  end

  def test_fetches_icon_from_api
    stub_request(:get, "https://api.iconify.design/lucide.json?icons=check")
      .to_return(
        status: 200,
        body: iconify_response("check", body: '<path d="M20 6L9 17l-5-5"/>').to_json,
        headers: {"Content-Type" => "application/json"}
      )

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert result
    assert_includes result[:body], "path"
    assert_equal 24, result[:width]
    assert_equal 24, result[:height]
  end

  def test_uses_icon_level_dimensions_over_top_level
    stub_request(:get, "https://api.iconify.design/mdi.json?icons=alert")
      .to_return(
        status: 200,
        body: {
          prefix: "mdi",
          width: 24,
          height: 24,
          icons: {
            "alert" => {body: "<path/>", width: 32, height: 32}
          }
        }.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    result = Kiso::Icons::ApiClient.fetch_icon("mdi", "alert")
    assert_equal 32, result[:width]
    assert_equal 32, result[:height]
  end

  def test_falls_back_to_top_level_dimensions
    stub_request(:get, "https://api.iconify.design/lucide.json?icons=check")
      .to_return(
        status: 200,
        body: {
          prefix: "lucide",
          width: 24,
          height: 24,
          icons: {
            "check" => {body: "<path/>"}
          }
        }.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_equal 24, result[:width]
    assert_equal 24, result[:height]
  end

  def test_returns_nil_for_404
    stub_request(:get, "https://api.iconify.design/lucide.json?icons=nonexistent")
      .to_return(status: 404)

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "nonexistent")
    assert_nil result
  end

  def test_returns_nil_for_server_error
    stub_request(:get, "https://api.iconify.design/lucide.json?icons=check")
      .to_return(status: 500)

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_nil result
  end

  def test_returns_nil_on_timeout
    stub_request(:get, "https://api.iconify.design/lucide.json?icons=check")
      .to_timeout

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_nil result
  end

  def test_returns_nil_on_connection_refused
    stub_request(:get, "https://api.iconify.design/lucide.json?icons=check")
      .to_raise(Errno::ECONNREFUSED)

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_nil result
  end

  def test_returns_nil_for_missing_icon_in_response
    stub_request(:get, "https://api.iconify.design/lucide.json?icons=check")
      .to_return(
        status: 200,
        body: {prefix: "lucide", width: 24, height: 24, icons: {}}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_nil result
  end

  def test_returns_nil_for_invalid_json
    stub_request(:get, "https://api.iconify.design/lucide.json?icons=check")
      .to_return(
        status: 200,
        body: "not json",
        headers: {"Content-Type" => "application/json"}
      )

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_nil result
  end

  def test_defaults_dimensions_to_24_when_absent_everywhere
    stub_request(:get, "https://api.iconify.design/lucide.json?icons=check")
      .to_return(
        status: 200,
        body: {icons: {"check" => {body: "<path/>"}}}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_equal 24, result[:width]
    assert_equal 24, result[:height]
  end

  private

  def iconify_response(icon_name, body:, width: 24, height: 24)
    {
      prefix: "lucide",
      width: width,
      height: height,
      icons: {
        icon_name => {body: body}
      }
    }
  end
end
