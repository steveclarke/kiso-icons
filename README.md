# Kiso Icons 基礎

Iconify icons for Rails — vendor pattern like importmap-rails.

Pin any of [Iconify's 224 icon sets](https://icon-sets.iconify.design/) (299k+ icons) to `vendor/icons/`. Inline SVG rendering, zero JavaScript, vendored for production.

Part of the [Kiso 基礎](https://github.com/steveclarke/kiso) UI component family. Works standalone in any Rails 8+ app — no other Kiso gems required.

## Installation

Add to your Gemfile:

```ruby
gem "kiso-icons"
```

Then run the installer:

```bash
bundle install
bin/rails kiso_icons:install
```

This creates `vendor/icons/` and a `bin/kiso-icons` binstub.

## Usage

### Pin icon sets

```bash
bin/kiso-icons pin lucide
bin/kiso-icons pin heroicons mdi tabler
```

### Render icons in views

```erb
<%= kiso_icon_tag("lucide:check") %>
<%= kiso_icon_tag("check") %>                          <%# uses default set (lucide) %>
<%= kiso_icon_tag("check", class: "w-5 h-5") %>       <%# pass any CSS classes %>
<%= kiso_icon_tag("check", aria: { label: "Done" }) %> <%# accessible icon %>
```

### CLI commands

```bash
bin/kiso-icons pin SETS...   # Download icon sets to vendor/icons/
bin/kiso-icons unpin SET     # Remove a vendored icon set
bin/kiso-icons pristine      # Re-download all pinned icon sets
bin/kiso-icons list          # Show pinned icon sets
```

## How it works

Kiso Icons follows the same vendor pattern as importmap-rails:

1. **Pin** icon sets from Iconify's repository to `vendor/icons/`
2. **Commit** the JSON files to git (just like vendored JavaScript)
3. **Render** icons as inline SVG with `kiso_icon_tag()`

Icons are resolved through a cascade: vendored JSON → bundled Lucide (ships with the gem) → Iconify API fallback (development only).

The rendered SVG uses `width="1em" height="1em"` and `currentColor` — it inherits size from font-size and color from the parent element. No CSS framework dependency.

## Bundled icons

Lucide ships with the gem (81KB gzipped) for zero-config usage. No need to pin it unless you want to update to a newer version.

## Development

```bash
git clone https://github.com/steveclarke/kiso-icons.git
cd kiso-icons
bin/setup    # install deps + pin demo icon sets
bin/dev      # start demo app on http://localhost:3100
```

`bin/dev` starts a dummy Rails app that renders home icons from 10 different icon sets. Pass a port number to change the default: `bin/dev 4200`.

Run tests:

```bash
bundle exec rake test            # unit tests (no Rails)
bundle exec rake test_integration # integration tests (boots Rails)
bundle exec rake                  # both
```

## License

MIT License. See [MIT-LICENSE](MIT-LICENSE).
