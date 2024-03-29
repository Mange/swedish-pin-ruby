# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Nothing yet.

## [2.0.0] - 2023-01-11

### Breaking changes

* Minimum supported Ruby version bumped from 2.5 to 2.7.

### Fixed

* PINs with future birthdates are now parsed as long as they are for the
  current year.
    * **Example:** `20xyab-nnnn` used to be parsed as `1920` until `2020-xy-ab`,
    but now it's parsed as `2020` from 2020-01-01 and onwards. This is more
    correct, since all 1920s PINs should be written with a `+` after
    2020-01-01.
* Parsing of 10-digit PINs were improved so it is always consistent so
  `parse(pin.to_s(10)) == pin`.

### Removed

* Explicit installation of `rake` and `minitest` as development dependencies
  removed. Now relying on the versions bundled with Ruby.

### Other

* Travis CI setup changed into Github Actions.

## [1.1.0] - 2022-07-04

### Fixed

* `rake test` actually runs tests now.

### Added

* `Personnummer` can now be compared and sorted.
* `Personnummer` works as hash keys by value.

## [1.0.0] - 2020-09-09

Initial release.

[1.0.0]: https://github.com/Mange/swedish-pin-ruby/releases/tag/v1.0.0
[1.1.0]: https://github.com/Mange/swedish-pin-ruby/releases/tag/v1.1.0
[2.0.0]: https://github.com/Mange/swedish-pin-ruby/releases/tag/v2.0.0
[Unreleased]: https://github.com/Mange/swedish-pin-ruby/compare/v2.0.0...HEAD
