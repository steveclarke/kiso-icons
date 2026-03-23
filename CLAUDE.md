# CLAUDE.md

## Commands

```bash
bin/setup                          # Install deps + pin demo icon sets
bin/rake                           # All tests (unit + integration)
bin/rake test                      # Unit tests only
bin/rake test_integration          # Integration tests only
bundle exec ruby -Itest test/resolver_test.rb                              # Single file
bundle exec ruby -Itest test/resolver_test.rb -n test_resolves_with_prefix # Single test
bin/standardrb                     # Lint (StandardRB)
bin/standardrb --fix               # Auto-fix lint
```

## Test Setup

Two separate test suites with different boot paths:

- **Unit tests** (`test/*_test.rb`) require `test_helper.rb` — loads the gem directly, no Rails. Use `TestFixtures` module for sample icon set data and `TestFixtures.write_vendor_set`/`write_bundled_set` helpers to set up temp directories.
- **Integration tests** (`test/integration/*_test.rb`) require `test/integration_test_helper.rb` — boots the dummy Rails app in `test/dummy/`. These can use `ActionDispatch::IntegrationTest` and hit routes defined in `test/dummy/config/routes.rb`.

Unit tests mock all HTTP with WebMock (included via `webmock/minitest`). Icon set file I/O in unit tests should use `Dir.mktmpdir` for isolation.

## Architecture Notes

Resolver resolution cascade (order matters): cache → loaded sets → vendor JSON → bundled gzip → API. Set alias resolution follows transforms (rotate/flip) up to 5 levels deep.

Railtie sets `fallback_to_api` true in dev/test, false in production.
