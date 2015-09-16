# v0.1.2 2015-09-16
### Added

  - Projections (`container.relation(:users).project(:id, :name)`) (AMHOL)

[Compare v0.1.1...v0.1.2](https://github.com/rom-rb/rom-http/compare/v0.1.1...v0.1.2)

# v0.1.1 2015-09-03
### Added

  - `ROM::HTTP::Dataset` macros for setting `default_request_handler` and `default_response_handler` (AMHOL)

### Changed

- `ROM::HTTP::Gateway` tries to load the `Dataset` class lazily from the same namespace that the `Gateway` is defined in, with a fallback to `ROM::HTTP::Dataset`, making extending easier (AMHOL)
- `ROM::HTTP::Gateway` no longer raises errors on missing configuration keys, these are now raised late in `Dataset` - this was to allow for the implementation of `default_request_handler` and `default_response_handler` (AMHOL)
- `ROM::HTTP::Dataset` now uses `ROM::Options` from `rom-support`, adding typechecking to options and making it easier to define additional options in extensions

[Compare v0.1.0...v0.1.1](https://github.com/rom-rb/rom-http/compare/v0.1.0...v0.1.1)

# v0.1.0 2015-08-19

First public release \o/
