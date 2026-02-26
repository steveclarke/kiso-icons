# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "kiso/icons"
require "minitest/autorun"
require "webmock/minitest"
require "tmpdir"
require "fileutils"

# Silence log output during tests — null logger survives reset! calls
Kiso::Icons::Configuration.prepend(Module.new {
  def logger
    @logger ||= Logger.new(File::NULL)
  end
})

# Create a small test icon set fixture
module TestFixtures
  ICON_SET_DATA = {
    "prefix" => "test",
    "info" => {"name" => "Test Icons"},
    "width" => 24,
    "height" => 24,
    "icons" => {
      "check" => {
        "body" => '<path d="M20 6L9 17l-5-5" stroke="currentColor" stroke-width="2"/>'
      },
      "arrow-right" => {
        "body" => '<path d="M5 12h14M12 5l7 7-7 7" stroke="currentColor" stroke-width="2"/>',
        "width" => 24,
        "height" => 24
      },
      "custom-size" => {
        "body" => '<circle cx="8" cy="8" r="8"/>',
        "width" => 16,
        "height" => 16
      }
    },
    "aliases" => {
      "checkmark" => {"parent" => "check"},
      "forward" => {"parent" => "arrow-right"},
      "flipped" => {"parent" => "check", "hFlip" => true},
      "rotated" => {"parent" => "check", "rotate" => 1},
      "deep-alias" => {"parent" => "checkmark"}
    }
  }.freeze

  def self.write_vendor_set(dir, prefix, data = ICON_SET_DATA)
    vendor_dir = File.join(dir, "vendor", "icons")
    FileUtils.mkdir_p(vendor_dir)
    File.write(File.join(vendor_dir, "#{prefix}.json"), JSON.generate(data))
  end

  def self.write_bundled_set(path, prefix, data = ICON_SET_DATA)
    FileUtils.mkdir_p(path)
    json = JSON.generate(data)
    gz_path = File.join(path, "#{prefix}.json.gz")
    Zlib::GzipWriter.open(gz_path) { |gz| gz.write(json) }
  end
end
