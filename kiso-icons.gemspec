# frozen_string_literal: true

require_relative "lib/kiso/icons/version"

Gem::Specification.new do |spec|
  spec.name = "kiso-icons"
  spec.version = Kiso::Icons::VERSION
  spec.authors = ["Steve Clarke"]
  spec.email = ["steve@sevenview.ca"]
  spec.homepage = "https://github.com/steveclarke/kiso-icons"
  spec.summary = "Iconify icons for Rails"
  spec.description = "Pin any of Iconify's 224 icon sets (299k icons) to vendor/icons/. " \
                     "Inline SVG rendering, zero JavaScript, vendored for production."
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{data,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 8.0"
  spec.add_dependency "activesupport", ">= 8.0"
  spec.add_dependency "actionpack", ">= 8.0"

  spec.add_development_dependency "yard"
end
