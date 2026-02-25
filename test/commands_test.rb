# frozen_string_literal: true

require "test_helper"
require "kiso/icons/commands"

class CommandsTest < Minitest::Test
  def setup
    Kiso::Icons.reset!
    WebMock.enable!
    @tmpdir = Dir.mktmpdir
    @original_dir = Dir.pwd
    Dir.chdir(@tmpdir)
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@tmpdir)
    Kiso::Icons.reset!
    WebMock.reset!
  end

  def test_pin_downloads_icon_set
    icon_data = JSON.generate(TestFixtures::ICON_SET_DATA)
    stub_request(:get, "https://raw.githubusercontent.com/iconify/icon-sets/master/json/test.json")
      .to_return(status: 200, body: icon_data)

    capture_io { Kiso::Icons::Commands.start(["pin", "test"]) }

    path = File.join(@tmpdir, "vendor", "icons", "test.json")
    assert File.exist?(path), "Expected #{path} to exist"
    parsed = JSON.parse(File.read(path))
    assert parsed["icons"]
  end

  def test_pin_skips_existing
    FileUtils.mkdir_p(File.join(@tmpdir, "vendor", "icons"))
    File.write(File.join(@tmpdir, "vendor", "icons", "test.json"), "{}")

    output, = capture_io { Kiso::Icons::Commands.start(["pin", "test"]) }
    assert_includes output, "exists"
  end

  def test_unpin_removes_set
    FileUtils.mkdir_p(File.join(@tmpdir, "vendor", "icons"))
    path = File.join(@tmpdir, "vendor", "icons", "test.json")
    File.write(path, "{}")

    capture_io { Kiso::Icons::Commands.start(["unpin", "test"]) }
    refute File.exist?(path)
  end

  def test_unpin_reports_missing
    output, = capture_io { Kiso::Icons::Commands.start(["unpin", "missing"]) }
    assert_includes output, "not found"
  end

  def test_list_shows_pinned_sets
    FileUtils.mkdir_p(File.join(@tmpdir, "vendor", "icons"))
    File.write(
      File.join(@tmpdir, "vendor", "icons", "test.json"),
      JSON.generate(TestFixtures::ICON_SET_DATA)
    )

    output, = capture_io { Kiso::Icons::Commands.start(["list"]) }
    assert_includes output, "test"
    assert_includes output, "icons"
  end

  def test_list_shows_empty_message
    output, = capture_io { Kiso::Icons::Commands.start(["list"]) }
    assert_includes output, "No icon sets pinned"
  end

  def test_pristine_redownloads_all
    FileUtils.mkdir_p(File.join(@tmpdir, "vendor", "icons"))
    File.write(
      File.join(@tmpdir, "vendor", "icons", "test.json"),
      JSON.generate(TestFixtures::ICON_SET_DATA)
    )

    updated_data = TestFixtures::ICON_SET_DATA.dup
    updated_data["icons"] = {"check" => {"body" => '<path d="UPDATED"/>'}}

    stub_request(:get, "https://raw.githubusercontent.com/iconify/icon-sets/master/json/test.json")
      .to_return(status: 200, body: JSON.generate(updated_data))

    capture_io { Kiso::Icons::Commands.start(["pristine"]) }

    content = File.read(File.join(@tmpdir, "vendor", "icons", "test.json"))
    assert_includes content, "UPDATED"
  end

  def test_exit_on_failure_returns_false
    refute Kiso::Icons::Commands.exit_on_failure?
  end
end
