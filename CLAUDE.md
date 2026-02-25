# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kiso Icons is a Rails gem that brings Iconify's 224 icon sets (299k+ icons) to Rails applications as inline SVGs with zero JavaScript. Icons are "pinned" (vendored as JSON) and committed to version control, similar to how importmap-rails works.

## Commands

```bash
# Setup
bin/setup                          # Install deps + pin demo icon sets

# Tests
bundle exec rake                   # All tests (unit + integration)
bundle exec rake test              # Unit tests only (no Rails boot)
bundle exec rake test_integration  # Integration tests (boots dummy Rails app)

# Run a single test file
bundle exec ruby -Itest test/resolver_test.rb

# Run a single test by name
bundle exec ruby -Itest test/resolver_test.rb -n test_resolves_icon_with_set_prefix

# Lint
bundle exec standardrb             # Check
bundle exec standardrb --fix       # Auto-fix

# Demo app
bin/dev [PORT]                     # Starts dummy Rails app (default: port 3100)
```

## Architecture

### Icon Resolution Cascade (Resolver)

When `kiso_icon_tag("lucide:check")` is called, the Resolver finds icons through a priority cascade:

1. **In-memory cache** — thread-safe Cache with Mutex
2. **Already-loaded sets** — Resolver's `@loaded_sets` hash
3. **Vendored JSON** — `vendor/icons/*.json` committed to the app's repo
4. **Bundled Lucide** — `data/lucide.json.gz` shipped with the gem
5. **Iconify API fallback** — dev/test only, disabled in production

### Key Classes

- **Resolver** (`lib/kiso/icons/resolver.rb`) — orchestrates icon lookup through the cascade, parses `"set:icon"` notation, falls back to `default_set` for bare names
- **Set** (`lib/kiso/icons/set.rb`) — loads/parses Iconify JSON, resolves aliases with transforms (rotate, hFlip, vFlip), max alias depth of 5
- **Renderer** (`lib/kiso/icons/renderer.rb`) — builds inline SVG strings with `width="1em"`, `currentColor`, viewBox, aria-hidden; supports `class:`, `data:`, `aria:` attributes; HTML-escapes to prevent XSS
- **Helper** (`lib/kiso/icons/helper.rb`) — provides `kiso_icon_tag()` view helper, included into ActionView via Railtie
- **Commands** (`lib/kiso/icons/commands.rb`) — Thor CLI (`bin/kiso-icons pin|unpin|pristine|list`), downloads icon sets from GitHub
- **ApiClient** (`lib/kiso/icons/api_client.rb`) — Iconify API client for dev-only fallback
- **Railtie** (`lib/kiso/icons/railtie.rb`) — Rails integration: sets `fallback_to_api` per environment, includes helper, loads rake tasks

### Test Structure

- **Unit tests** (`test/*_test.rb`) — no Rails dependency, use temp dirs for file I/O, mock HTTP with WebMock
- **Integration tests** (`test/integration/*_test.rb`) — boot the dummy Rails app in `test/dummy/`
- **Test fixtures** (`test/fixtures/`) — sample icon set JSON data
- **TestFixtures module** (`test/test_helper.rb`) — shared fixture helpers used across tests

### Runtime Dependencies

Rails 8.0+ (railties, activesupport, actionpack). Linting uses StandardRB.
