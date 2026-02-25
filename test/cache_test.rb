# frozen_string_literal: true

require "test_helper"

class CacheTest < Minitest::Test
  def setup
    @cache = Kiso::Icons::Cache.new
  end

  def test_get_returns_nil_for_missing_key
    assert_nil @cache.get("lucide", "nonexistent")
  end

  def test_set_and_get
    data = {body: "<path/>", width: 24, height: 24}
    @cache.set("lucide", "check", data)
    assert_equal data, @cache.get("lucide", "check")
  end

  def test_set_freezes_data
    data = {body: "<path/>", width: 24, height: 24}
    @cache.set("lucide", "check", data)
    cached = @cache.get("lucide", "check")
    assert cached.frozen?
  end

  def test_size
    assert_equal 0, @cache.size
    @cache.set("lucide", "check", {body: "<path/>"})
    assert_equal 1, @cache.size
    @cache.set("lucide", "x", {body: "<path/>"})
    assert_equal 2, @cache.size
  end

  def test_clear
    @cache.set("lucide", "check", {body: "<path/>"})
    @cache.set("lucide", "x", {body: "<path/>"})
    @cache.clear!
    assert_equal 0, @cache.size
    assert_nil @cache.get("lucide", "check")
  end

  def test_different_sets_same_name
    data_a = {body: "<path a/>"}
    data_b = {body: "<path b/>"}
    @cache.set("lucide", "check", data_a)
    @cache.set("mdi", "check", data_b)
    assert_equal data_a, @cache.get("lucide", "check")
    assert_equal data_b, @cache.get("mdi", "check")
  end

  def test_thread_safety
    threads = 10.times.map do |i|
      Thread.new do
        100.times do |j|
          @cache.set("set#{i}", "icon#{j}", {body: "#{i}-#{j}"})
          @cache.get("set#{i}", "icon#{j}")
        end
      end
    end
    threads.each(&:join)
    assert @cache.size > 0
  end
end
