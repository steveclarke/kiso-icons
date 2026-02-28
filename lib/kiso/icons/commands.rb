# frozen_string_literal: true

require "thor"
require "kiso/icons"

# Thor CLI for managing vendored Iconify icon sets.
#
# Downloads full icon set JSON from GitHub's raw content URL for the
# iconify/icon-sets repo. Designed for the +bin/kiso-icons+ binstub.
#
# @example Pin icon sets
#   $ bin/kiso-icons pin lucide heroicons
#
# @example List pinned sets
#   $ bin/kiso-icons list
class Kiso::Icons::Commands < Thor
  include Thor::Actions

  # Base URL for downloading Iconify JSON files from GitHub.
  SETS_URL = "https://raw.githubusercontent.com/iconify/icon-sets/master/json"

  def self.exit_on_failure? = false

  desc "pin SETS...", "Download icon sets to vendor/icons/"
  long_desc <<~DESC
    Downloads Iconify JSON files for the specified icon sets to vendor/icons/.
    Commit these files to git for production use (like importmap-rails vendor pattern).

    Example:
      $ bin/kiso-icons pin lucide
      $ bin/kiso-icons pin heroicons mdi tabler
  DESC

  # Downloads one or more icon sets to +vendor/icons/+.
  #
  # @param sets [Array<String>] icon set prefixes to download
  # @return [void]
  def pin(*sets)
    if sets.empty?
      say "Usage: bin/kiso-icons pin SET [SET...]", :red
      say ""
      say "Example: bin/kiso-icons pin lucide heroicons"
      say "Browse sets: https://icon-sets.iconify.design/"
      exit 1
    end

    vendor_dir = vendor_path
    FileUtils.mkdir_p(vendor_dir)

    sets.each { |set_name| pin_set(set_name, vendor_dir) }
  end

  desc "unpin SET", "Remove a vendored icon set"

  # Removes a vendored icon set from disk.
  #
  # @param set_name [String] the icon set prefix to remove
  # @return [void]
  def unpin(set_name)
    path = File.join(vendor_path, "#{set_name}.json")

    unless File.exist?(path)
      say "  not found  #{set_name} is not pinned", :red
      return
    end

    File.delete(path)
    say "  remove  vendor/icons/#{set_name}.json", :green
  end

  desc "pristine", "Re-download all pinned icon sets"

  # Re-downloads all currently pinned icon sets from GitHub.
  #
  # @return [void]
  def pristine
    sets = vendored_sets
    if sets.empty?
      say "No icon sets pinned. Pin one with: bin/kiso-icons pin lucide", :yellow
      return
    end

    vendor_dir = vendor_path
    say "Re-downloading #{sets.size} pinned set(s)..."
    sets.each { |set_name| pin_set(set_name, vendor_dir, overwrite: true) }
  end

  desc "list", "Show pinned icon sets"

  # Lists all pinned icon sets with icon count and file size.
  #
  # @return [void]
  def list
    sets = vendored_sets
    if sets.empty?
      say "No icon sets pinned.", :yellow
      say ""
      say "Pin a set:  bin/kiso-icons pin lucide"
      return
    end

    say "Pinned icon sets (vendor/icons/):", :cyan
    say ""

    sets.each do |set_name|
      path = File.join(vendor_path, "#{set_name}.json")
      size_kb = (File.size(path) / 1024.0).round(1)
      data = JSON.parse(File.read(path))
      icon_count = (data["icons"] || {}).size
      display_name = data.dig("info", "name") || set_name

      say "  #{set_name.ljust(20)} #{icon_count.to_s.rjust(6)} icons  #{size_kb.to_s.rjust(8)} KB  (#{display_name})"
    end
  end

  private

  # Downloads and saves a single icon set to the vendor directory.
  #
  # @param set_name [String] the icon set prefix
  # @param vendor_dir [String] absolute path to the vendor directory
  # @param overwrite [Boolean] whether to overwrite an existing file
  # @return [void]
  def pin_set(set_name, vendor_dir, overwrite: false)
    dest = File.join(vendor_dir, "#{set_name}.json")

    if File.exist?(dest) && !overwrite
      say "  exists  vendor/icons/#{set_name}.json (use `pristine` to re-download)", :yellow
      return
    end

    url = "#{SETS_URL}/#{set_name}.json"
    say "  fetch   #{url}"

    body = download(url)
    if body.nil?
      say "  error   Could not download #{set_name}. Check the set name.", :red
      say "          Browse sets: https://icon-sets.iconify.design/"
      return
    end

    body = body.force_encoding("UTF-8")

    data = JSON.parse(body)
    unless data["icons"]
      say "  error   #{set_name}.json has no 'icons' key -- invalid Iconify format", :red
      return
    end

    File.write(dest, body)
    icon_count = data["icons"].size
    size_kb = (body.bytesize / 1024.0).round(1)
    say "  pin     vendor/icons/#{set_name}.json (#{icon_count} icons, #{size_kb} KB)", :green
  end

  # Downloads a URL, following up to +redirect_limit+ redirects.
  #
  # @param url [String] the URL to download
  # @param redirect_limit [Integer] maximum number of redirects to follow
  # @return [String, nil] the response body, or nil on error
  def download(url, redirect_limit = 5)
    raise "Too many redirects" if redirect_limit == 0

    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    case response
    when Net::HTTPSuccess then response.body
    when Net::HTTPRedirection then download(response["location"], redirect_limit - 1)
    end
  rescue SocketError, Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED => e
    say "  error   Network error: #{e.message}", :red
    nil
  end

  # Returns the absolute path to the vendor icons directory.
  #
  # @return [String]
  def vendor_path
    base = if defined?(Rails) && Rails.root
      Rails.root.to_s
    else
      Dir.pwd
    end
    File.join(base, Kiso::Icons.configuration.vendor_path)
  end

  # Returns sorted prefixes of all vendored icon sets.
  #
  # @return [Array<String>]
  def vendored_sets
    Dir.glob(File.join(vendor_path, "*.json"))
      .map { |f| File.basename(f, ".json") }
      .sort
  end
end
