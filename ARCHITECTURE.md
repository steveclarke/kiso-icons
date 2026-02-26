# Architecture

Kiso Icons is a Rails 8+ gem for zero-JavaScript, inline SVG icon rendering. It provides access to Iconify's 200+ icon sets (300,000+ icons) with a simple view helper, vendoring icons as JSON for production reliability.

## How an icon gets rendered

When you write `<%= kiso_icon_tag("lucide:check", class: "w-5 h-5") %>` in a view, here's what happens:

```
View helper (kiso_icon_tag)
  │
  ▼
Resolver ── parse name ── "lucide:check" → prefix: "lucide", name: "check"
  │
  ▼
Resolution cascade (first match wins):
  1. In-memory cache        ← instant, keyed by "lucide:check"
  2. Already-loaded Set     ← set was parsed on a previous request
  3. Vendor JSON            ← vendor/icons/lucide.json (committed to git)
  4. Bundled gzip           ← data/lucide.json.gz (ships with the gem)
  │
  ▼
Set ── find icon ── resolve aliases + apply transforms (rotate, flip)
  │
  ▼
Renderer ── build SVG ── sanitize body (Loofah) ── escape attributes
  │
  ▼
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     width="1em" height="1em" class="w-5 h-5" aria-hidden="true" fill="none">
  <path d="M20 6L9 17l-5-5"/>
</svg>
```

If the icon isn't found, development mode returns an HTML comment (`<!-- kiso-icons: 'name' not found -->`); production returns an empty string.

## Core classes

All classes live under `Kiso::Icons` in `lib/kiso/icons/`.

### Resolver (`resolver.rb`)

The central orchestrator. Owns the resolution cascade shown above, manages loaded sets, and coordinates caching. Thread-safe via Mutex on the loaded sets dictionary.

### Set (`set.rb`)

Wraps an Iconify JSON file (the standard format used by the Iconify ecosystem). Handles:

- **Icon lookup** by name from the `icons` hash
- **Alias resolution** — an alias points to a parent icon and optionally applies transforms. Aliases can chain up to 5 levels deep.
- **Transforms** — `rotate` (0-3, in 90-degree increments), `hFlip`, `vFlip`. Applied by wrapping the icon body in a `<g transform="...">` element.

Factory methods: `Set.from_vendor(prefix)` loads from `vendor/icons/`, `Set.from_bundled(prefix)` loads from gzipped `data/` directory.

### Cache (`cache.rb`)

Simple in-memory hash keyed by `"prefix:name"`. Thread-safe via Mutex. Cached entries are frozen to prevent mutation.

### Renderer (`renderer.rb`)

Produces the final SVG string. Responsibilities:

- Sets sensible defaults: `width="1em"`, `height="1em"`, `aria-hidden="true"`, `fill="none"`
- Handles `css_class`, `data-*`, and `aria-*` attribute expansion
- **Accessibility**: when `aria: { label: "..." }` is provided, removes `aria-hidden` and adds `role="img"` so screen readers announce the icon
- **Security**: sanitizes the SVG body using Loofah with a custom scrubber that strips `<script>`, `<foreignobject>`, event handlers (`on*`), and `javascript:` URLs
- Escapes all attribute values (`&`, `"`, `<`, `>`)

### Configuration (`configuration.rb`)

| Option | Default | Purpose |
|--------|---------|---------|
| `default_set` | `"lucide"` | Set prefix when icon name has no prefix |
| `vendor_path` | `"vendor/icons"` | Where pinned JSON files live |
| `logger` | stderr | Where warnings and debug info go |

### Helper (`helper.rb`)

Provides `kiso_icon_tag(name, **options)` to Rails views. Thin glue between Resolver and Renderer.

### Railtie (`railtie.rb`)

Auto-configures the gem when loaded in a Rails app:
- Points logger at `Rails.logger`
- Injects the Helper into `ActionView::Base`

## Icon sources

Icons come from two places:

| Source | What it provides | When it's used |
|--------|-----------------|----------------|
| **Vendored** (`vendor/icons/*.json`) | Full icon set JSON files, committed to your app's git repo | Any environment, when the set has been pinned via `bin/kiso-icons pin <set>`. |
| **Bundled** (`data/lucide.json.gz`) | Lucide set, gzipped, ships inside the gem | Any environment. Zero-config default so the gem works out of the box. |

The CLI downloads full sets from `https://raw.githubusercontent.com/iconify/icon-sets/master/json/{set}.json` on GitHub rather than the Iconify API, which is designed for single-icon lookups rather than bulk downloads.

## CLI (`commands.rb`)

Thor-based commands exposed via `bin/kiso-icons`:

| Command | Purpose |
|---------|---------|
| `pin lucide heroicons` | Download full icon set JSON files to `vendor/icons/` |
| `unpin heroicons` | Remove a vendored set |
| `pristine` | Re-download all pinned sets (update to latest) |
| `list` | Show pinned sets with icon counts and file sizes |

## Thread safety

Both the Resolver and Cache use Mutex locks to protect shared state. The Resolver locks around its `@loaded_sets` dictionary; the Cache locks around its `@store` hash and freezes all cached data. This makes concurrent icon resolution safe in threaded servers like Puma.

## Test structure

Two separate suites with different boot paths:

- **Unit tests** (`test/*_test.rb`) — require `test_helper.rb`, load the gem directly with no Rails. Use `TestFixtures` for sample data and `Dir.mktmpdir` for file isolation. All HTTP is mocked via WebMock.
- **Integration tests** (`test/integration/*_test.rb`) — require `integration_test_helper.rb`, boot the dummy Rails app in `test/dummy/`. Use `ActionDispatch::IntegrationTest` to hit real routes and verify end-to-end behavior.

## File map

```
lib/
  kiso/
    icons.rb                  # Module entry point, singleton accessors, .resolve()
    icons/
      cache.rb                # In-memory icon cache
      commands.rb             # Thor CLI (pin/unpin/pristine/list)
      configuration.rb        # Config object
      helper.rb               # kiso_icon_tag view helper
      railtie.rb              # Rails auto-configuration
      renderer.rb             # SVG generation and sanitization
      resolver.rb             # Resolution cascade orchestrator
      set.rb                  # Iconify JSON parsing and alias resolution
  install/
    install.rb                # Rails installer template
  tasks/
    kiso_icons_tasks.rake     # Rake task for installation
data/
  lucide.json.gz              # Bundled Lucide icon set
test/
  test_helper.rb              # Unit test setup + TestFixtures
  integration_test_helper.rb  # Integration test setup (boots dummy app)
  dummy/                      # Minimal Rails app for integration tests
```
