# frozen_string_literal: true

require "test_helper"

class SetTest < Minitest::Test
  def setup
    @set = Kiso::Icons::Set.new(prefix: "test", data: TestFixtures::ICON_SET_DATA)
  end

  def test_icon_lookup
    result = @set.icon("check")
    assert result
    assert_includes result[:body], "stroke"
    assert_equal 24, result[:width]
    assert_equal 24, result[:height]
  end

  def test_icon_returns_nil_for_missing
    assert_nil @set.icon("nonexistent")
  end

  def test_custom_size_icon
    result = @set.icon("custom-size")
    assert_equal 16, result[:width]
    assert_equal 16, result[:height]
  end

  def test_alias_resolution
    result = @set.icon("checkmark")
    assert result
    assert_includes result[:body], "stroke"
  end

  def test_deep_alias_resolution
    result = @set.icon("deep-alias")
    assert result
    assert_includes result[:body], "stroke"
  end

  def test_hflip_transform
    result = @set.icon("flipped")
    assert result
    assert_includes result[:body], "<g transform="
    assert_includes result[:body], "scale(-1 1)"
  end

  def test_rotate_transform
    result = @set.icon("rotated")
    assert result
    assert_includes result[:body], "<g transform="
    assert_includes result[:body], "rotate(90"
  end

  def test_icon_names_includes_icons_and_aliases
    names = @set.icon_names
    assert_includes names, "check"
    assert_includes names, "arrow-right"
    assert_includes names, "checkmark"
    assert_includes names, "flipped"
  end

  def test_icon_count
    assert_equal 3, @set.icon_count
  end

  def test_display_name
    assert_equal "Test Icons", @set.display_name
  end

  def test_display_name_fallback
    set = Kiso::Icons::Set.new(prefix: "foo", data: {"icons" => {}})
    assert_equal "foo", set.display_name
  end

  def test_default_dimensions
    assert_equal 24, @set.default_width
    assert_equal 24, @set.default_height
  end

  def test_from_vendor
    Dir.mktmpdir do |dir|
      TestFixtures.write_vendor_set(dir, "test")

      Dir.chdir(dir) do
        Kiso::Icons.reset!
        set = Kiso::Icons::Set.from_vendor("test")
        assert set
        assert_equal "test", set.prefix
        assert set.icon("check")
      end
    end
  ensure
    Kiso::Icons.reset!
  end

  def test_from_vendor_returns_nil_for_missing
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        Kiso::Icons.reset!
        assert_nil Kiso::Icons::Set.from_vendor("nonexistent")
      end
    end
  ensure
    Kiso::Icons.reset!
  end

  def test_from_bundled
    # The gem ships lucide.json.gz in data/
    set = Kiso::Icons::Set.from_bundled("lucide")
    assert set
    assert_equal "lucide", set.prefix
    assert set.icon("check")
    assert set.icon_count > 1000
  end

  def test_from_bundled_returns_nil_for_missing
    assert_nil Kiso::Icons::Set.from_bundled("nonexistent")
  end

  def test_vendored_sets
    Dir.mktmpdir do |dir|
      TestFixtures.write_vendor_set(dir, "alpha")
      TestFixtures.write_vendor_set(dir, "beta")

      Dir.chdir(dir) do
        Kiso::Icons.reset!
        sets = Kiso::Icons::Set.vendored_sets
        assert_equal ["alpha", "beta"], sets
      end
    end
  ensure
    Kiso::Icons.reset!
  end
end
