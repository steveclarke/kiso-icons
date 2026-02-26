# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0.pre] - 2026-02-25

### Added

- Inline SVG rendering via `kiso_icon_tag` helper
- CLI (`bin/kiso-icons`) for pinning, unpinning, and listing icon sets
- Support for all 224 Iconify icon sets (299k+ icons)
- Vendored Lucide icon set as zero-config default (81KB gzipped)
- Resolution cascade: vendored JSON → bundled Lucide → Iconify API fallback
- Thread-safe in-memory icon cache
- Alias resolution with rotation/flip transforms (up to 5 levels)
- Iconify API fallback in development with prompt to pin
- Rails generator (`kiso_icons:install`) for project setup
- `pristine` command to re-download all pinned sets

[Unreleased]: https://github.com/steveclarke/kiso-icons/compare/v0.1.0.pre...HEAD
[0.1.0.pre]: https://github.com/steveclarke/kiso-icons/releases/tag/v0.1.0.pre
