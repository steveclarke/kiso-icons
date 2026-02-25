# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bin/setup                          # Install deps + pin demo icon sets
bundle exec rake                   # All tests (unit + integration)
bundle exec rake test              # Unit tests only
bundle exec rake test_integration  # Integration tests only
bundle exec ruby -Itest test/resolver_test.rb                              # Single file
bundle exec ruby -Itest test/resolver_test.rb -n test_resolves_with_prefix # Single test
bundle exec standardrb             # Lint (StandardRB)
bundle exec standardrb --fix       # Auto-fix lint
```

## Test Setup

Two separate test suites with different boot paths:

- **Unit tests** (`test/*_test.rb`) require `test_helper.rb` — loads the gem directly, no Rails. Use `TestFixtures` module for sample icon set data and `TestFixtures.write_vendor_set`/`write_bundled_set` helpers to set up temp directories.
- **Integration tests** (`test/integration/*_test.rb`) require `test/integration_test_helper.rb` — boots the dummy Rails app in `test/dummy/`. These can use `ActionDispatch::IntegrationTest` and hit routes defined in `test/dummy/config/routes.rb`.

Unit tests mock all HTTP with WebMock (included via `webmock/minitest`). Icon set file I/O in unit tests should use `Dir.mktmpdir` for isolation.

## Architecture Notes

All classes live under `Kiso::Icons` in `lib/kiso/icons/`. The Resolver is the central orchestrator — it owns the resolution cascade (cache → loaded sets → vendor JSON → bundled gzip → API). The Set class handles Iconify JSON parsing including alias resolution with transforms (rotate/flip) up to 5 levels deep. The Renderer produces the final SVG string with HTML-escaped attributes.

The Railtie auto-configures `fallback_to_api` based on Rails environment (true in dev/test, false in production) and injects the `kiso_icon_tag` helper into ActionView.

The CLI (`lib/kiso/icons/commands.rb`) uses Thor and downloads icon set JSON from GitHub's raw content URL for the iconify/icon-sets repo.
