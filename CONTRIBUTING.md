# Contributing to Kiso Icons

Thanks for your interest in contributing! Here's how to get started.

## Setup

```bash
git clone https://github.com/steveclarke/kiso-icons.git
cd kiso-icons
bin/setup
```

## Running Tests

```bash
bundle exec rake              # all tests
bundle exec rake test          # unit tests only
bundle exec rake test_integration  # integration tests (boots Rails)
```

Run a single test file or method:

```bash
bundle exec ruby -Itest test/resolver_test.rb
bundle exec ruby -Itest test/resolver_test.rb -n test_resolves_with_prefix
```

## Code Style

This project uses [StandardRB](https://github.com/standardrb/standard). Check and auto-fix:

```bash
bundle exec standardrb        # check
bundle exec standardrb --fix  # auto-fix
```

## Submitting Changes

1. Fork the repo and create a branch from `main`
2. Add tests for any new functionality
3. Make sure all tests pass and linting is clean
4. Write a clear commit message ([Conventional Commits](https://www.conventionalcommits.org/) preferred)
5. Open a pull request

## Reporting Bugs

Open a [GitHub issue](https://github.com/steveclarke/kiso-icons/issues) with:

- Ruby and Rails versions
- What you expected vs. what happened
- Steps to reproduce
