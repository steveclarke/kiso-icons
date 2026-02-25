# frozen_string_literal: true

require "test_helper"

class ApiClientTest < Minitest::Test
  def setup
    WebMock.enable!
  end

  def teardown
    WebMock.reset!
  end

  def test_fetches_icon_from_api
    stub_request(:get, "https://api.iconify.design/lucide/check.json")
      .to_return(
        status: 200,
        body: '{"body":"<path d=\\"M20 6L9 17l-5-5\\"/>","width":24,"height":24}',
        headers: {"Content-Type" => "application/json"}
      )

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert result
    assert_includes result[:body], "path"
    assert_equal 24, result[:width]
    assert_equal 24, result[:height]
  end

  def test_returns_nil_for_404
    stub_request(:get, "https://api.iconify.design/lucide/nonexistent.json")
      .to_return(status: 404)

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "nonexistent")
    assert_nil result
  end

  def test_returns_nil_for_server_error
    stub_request(:get, "https://api.iconify.design/lucide/check.json")
      .to_return(status: 500)

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_nil result
  end

  def test_returns_nil_on_timeout
    stub_request(:get, "https://api.iconify.design/lucide/check.json")
      .to_timeout

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_nil result
  end

  def test_returns_nil_on_connection_refused
    stub_request(:get, "https://api.iconify.design/lucide/check.json")
      .to_raise(Errno::ECONNREFUSED)

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_nil result
  end

  def test_returns_nil_for_missing_body_in_response
    stub_request(:get, "https://api.iconify.design/lucide/check.json")
      .to_return(
        status: 200,
        body: '{"width":24,"height":24}',
        headers: {"Content-Type" => "application/json"}
      )

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_nil result
  end

  def test_returns_nil_for_invalid_json
    stub_request(:get, "https://api.iconify.design/lucide/check.json")
      .to_return(
        status: 200,
        body: "not json",
        headers: {"Content-Type" => "application/json"}
      )

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_nil result
  end

  def test_defaults_dimensions_to_24
    stub_request(:get, "https://api.iconify.design/lucide/check.json")
      .to_return(
        status: 200,
        body: '{"body":"<path/>"}',
        headers: {"Content-Type" => "application/json"}
      )

    result = Kiso::Icons::ApiClient.fetch_icon("lucide", "check")
    assert_equal 24, result[:width]
    assert_equal 24, result[:height]
  end
end
