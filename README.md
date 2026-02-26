# Kiso Icons 基礎

Iconify icons for Rails

Pin any of [Iconify's 224 icon sets](https://icon-sets.iconify.design/) (299k+ icons) to `vendor/icons/`. Inline SVG rendering, zero JavaScript, vendored for production.

Part of the [Kiso 基礎](https://github.com/steveclarke/kiso) UI component family. Works standalone in any Rails 8+ app — no other Kiso gems required.

## Installation

```bash
./bin/bundle add kiso-icons
./bin/rails kiso_icons:install
```

This creates `vendor/icons/` and a `bin/kiso-icons` binstub.

## Quick start

[Lucide](https://lucide.dev) ships with the gem — no pinning needed. Start using icons immediately:

```erb
<%= kiso_icon_tag("check") %>
<%= kiso_icon_tag("arrow-right") %>
```

Want a different icon set? Pin it:

```bash
./bin/kiso-icons pin heroicons
```

Then use it with the set prefix:

```erb
<%= kiso_icon_tag("heroicons:home") %>
```

Browse all available sets at [icon-sets.iconify.design](https://icon-sets.iconify.design/).

## Usage

```erb
<%= kiso_icon_tag("lucide:check") %>
<%= kiso_icon_tag("check") %>                          <%# uses default set (lucide) %>
<%= kiso_icon_tag("check", class: "w-5 h-5") %>       <%# pass any CSS classes %>
<%= kiso_icon_tag("check", aria: { label: "Done" }) %> <%# accessible icon %>
```

### Pin icon sets

Pin downloads an Iconify JSON file to `vendor/icons/`. Commit it to git, just like vendored JavaScript with importmap-rails.

```bash
./bin/kiso-icons pin lucide             # vendor Lucide (overrides the bundled copy)
./bin/kiso-icons pin heroicons mdi      # pin multiple sets at once
./bin/kiso-icons unpin heroicons        # remove a vendored set
./bin/kiso-icons pristine               # re-download all pinned sets
./bin/kiso-icons list                   # show what's pinned
```

## How it works

Icons are resolved through a cascade:

1. **Vendored JSON** — pinned sets in `vendor/icons/`
2. **Bundled Lucide** — ships with the gem (81KB gzipped), zero-config default
3. **Iconify API** — fallback in development only, with a prompt to pin

The rendered SVG uses `width="1em" height="1em"` and `currentColor` — it inherits size from font-size and color from the parent element. No CSS framework dependency.

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
