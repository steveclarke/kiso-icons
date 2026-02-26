# frozen_string_literal: true

require "test_helper"

class ResolverTest < Minitest::Test
  def setup
    Kiso::Icons.reset!
    @resolver = Kiso::Icons::Resolver.new
  end

  def teardown
    Kiso::Icons.reset!
  end

  def test_parses_prefixed_name
    Dir.mktmpdir do |dir|
      TestFixtures.write_vendor_set(dir, "test")

      Dir.chdir(dir) do
        result = @resolver.resolve("test:check")
        assert result
        assert_includes result[:body], "stroke"
      end
    end
  end

  def test_uses_default_set_for_bare_name
    Dir.mktmpdir do |dir|
      TestFixtures.write_vendor_set(dir, "lucide")

      Dir.chdir(dir) do
        Kiso::Icons.configure { |c| c.default_set = "lucide" }
        result = @resolver.resolve("check")
        assert result
      end
    end
  end

  def test_returns_nil_for_missing_icon
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        result = @resolver.resolve("nonexistent:missing")
        assert_nil result
      end
    end
  end

  def test_caches_resolved_icons
    Dir.mktmpdir do |dir|
      TestFixtures.write_vendor_set(dir, "test")

      Dir.chdir(dir) do
        result1 = @resolver.resolve("test:check")
        result2 = @resolver.resolve("test:check")
        assert_equal result1, result2
        assert_equal 1, Kiso::Icons.cache.size
      end
    end
  end

  def test_resolves_from_bundled
    # The gem ships lucide.json.gz in data/
    result = @resolver.resolve("lucide:check")
    assert result
    assert result[:body]
    assert_equal 24, result[:width]
    assert_equal 24, result[:height]
  end

  def test_vendor_takes_priority_over_bundled
    Dir.mktmpdir do |dir|
      custom_data = TestFixtures::ICON_SET_DATA.dup
      custom_data["icons"] = {
        "check" => {"body" => '<path d="CUSTOM"/>'}
      }
      TestFixtures.write_vendor_set(dir, "lucide", custom_data)

      Dir.chdir(dir) do
        result = @resolver.resolve("lucide:check")
        assert result
        assert_includes result[:body], "CUSTOM"
      end
    end
  end

  def test_strips_whitespace_from_name
    Dir.mktmpdir do |dir|
      TestFixtures.write_vendor_set(dir, "test")

      Dir.chdir(dir) do
        result = @resolver.resolve("  test:check  ")
        assert result
      end
    end
  end

  def test_clear_resets_loaded_sets
    Dir.mktmpdir do |dir|
      TestFixtures.write_vendor_set(dir, "test")

      Dir.chdir(dir) do
        @resolver.resolve("test:check")
        @resolver.clear!
        # After clear, sets need to be reloaded from disk
        result = @resolver.resolve("test:check")
        assert result
      end
    end
  end
end
