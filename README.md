# Kiso Icons 基礎

Iconify icons for Rails. Use any of [224 icon sets](https://icon-sets.iconify.design/) (299k+ icons) as inline SVG. No JavaScript needed.

Icons live in `vendor/icons/` as JSON files. Commit them to git, just like vendored JavaScript with importmap-rails.

Part of the [Kiso 基礎](https://github.com/steveclarke/kiso) family. Works on its own in any Rails 8+ app.

## Installation

```bash
./bin/bundle add kiso-icons
./bin/rails kiso_icons:install
```

This creates `vendor/icons/` and a `bin/kiso-icons` binstub.

## Quick start

[Lucide](https://lucide.dev) ships with the gem. Use it right away:

```erb
<%= kiso_icon_tag("check") %>
<%= kiso_icon_tag("arrow-right") %>
```

Want a different icon set? Pin it:

```bash
./bin/kiso-icons pin heroicons
```

Then use it with the set name as a prefix:

```erb
<%= kiso_icon_tag("heroicons:home") %>
```

Browse all sets at [icon-sets.iconify.design](https://icon-sets.iconify.design/).

## Usage

```erb
<%= kiso_icon_tag("lucide:check") %>
<%= kiso_icon_tag("check") %>                          <%# uses the default set (lucide) %>
<%= kiso_icon_tag("check", class: "w-5 h-5") %>       <%# add CSS classes %>
<%= kiso_icon_tag("check", aria: { label: "Done" }) %> <%# screen reader label %>
```

You can pass any HTML attribute. If you add `aria: { label: "..." }`, screen readers will see the icon and `aria-hidden` is removed.

### Pin icon sets

The `pin` command downloads an Iconify JSON file to `vendor/icons/`. Commit it to git. In production, icons load from these files with no API calls.

```bash
./bin/kiso-icons pin lucide             # pin Lucide (replaces the bundled copy)
./bin/kiso-icons pin heroicons mdi      # pin more than one set at once
./bin/kiso-icons unpin heroicons        # remove a set
./bin/kiso-icons pristine               # re-download all pinned sets
./bin/kiso-icons list                   # show what's pinned
```

## Configuration

Add an initializer to change the defaults:

```ruby
# config/initializers/kiso_icons.rb
Kiso::Icons.configure do |config|
  config.default_set = "lucide"        # icon set used when no prefix is given
  config.vendor_path = "vendor/icons"  # where pinned JSON files are stored
  config.fallback_to_api = false       # fetch missing icons from the Iconify API
end
```

| Option | Default | What it does |
|--------|---------|-------------|
| `default_set` | `"lucide"` | Icon set used when you write `kiso_icon_tag("check")` with no prefix. |
| `vendor_path` | `"vendor/icons"` | Where pinned JSON files are stored. |
| `fallback_to_api` | `true` in dev, `false` in prod | If `true`, missing icons are fetched from the Iconify API. A log message tells you to pin the set. |

> [!TIP]
> In production, `fallback_to_api` is off. Pin all the sets you need so icons load from local files.

## How it works

Icons are found in this order:

1. **Pinned JSON** — your sets in `vendor/icons/`
2. **Bundled Lucide** — ships with the gem (81 KB gzipped), works with no setup
3. **Iconify API** — only in dev mode, with a prompt to pin

Each SVG uses `width="1em"`, `height="1em"`, and `currentColor`. It inherits its size from `font-size` and its color from the parent element. No CSS framework needed.

## Development

```bash
git clone https://github.com/steveclarke/kiso-icons.git
cd kiso-icons
bin/setup    # install deps + pin demo icon sets
bin/dev      # start demo app at http://localhost:3100
```

`bin/dev` starts a Rails app that shows icons from 10 sets. You can change the port: `bin/dev 4200`.

Run tests:

```bash
bundle exec rake test            # unit tests (no Rails)
bundle exec rake test_integration # integration tests (boots Rails)
bundle exec rake                  # both
```

See [CONTRIBUTING.md](CONTRIBUTING.md) to help out.

## Project layout

```
bin/           dev scripts and CLI binstub
data/          bundled Lucide icon set (gzipped JSON)
lib/           gem source code
test/          unit and integration tests
test/dummy/    Rails app used for integration tests and the demo
```

## Requirements

- Ruby >= 3.2
- Rails >= 8.0

## License

MIT License. See [MIT-LICENSE](MIT-LICENSE).
