# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2020-06-15

### Changed

- fix bug with fragments on same object with different fields
- fix issue when using a fragment spread on an interface type

## [0.2.0] - 2020-05-10

### Changed

- add to ferry monorepo


## [0.1.4] - 2020-02-22

### Changed

- transfer to gql-dart org

## [0.1.3] - 2020-02-11

### Changed

- fix issue with unmodifiable lists

## [0.1.2] - 2020-02-08

### Changed

- fix map type issue

## [0.1.1] - 2020-02-03

### Changed

- update readme

## [0.1.0] - 2020-02-03

### Changed

- use `reader` and `writer` instead of passing objects directly

## [0.0.8] - 2020-02-03

### Added

- make normalization agnostic to argument order

## [0.0.7] - 2020-01-25

### Added

- allow user to specify whether partial data should be returned (defaults to false)

## [0.0.6] - 2020-01-11

### Changed

- use standart Json type
- update `gql` dependency

## [0.0.5] - 2020-01-01

### Changed

- `denormalize` and `denormalizeFragment` now return null if there is a existing data with different variables in the map (they previously returned an empty object).

## [0.0.4] - 2019-12-30

### Added

- operationName parameter for multi-operation documents

## [0.0.3] - 2019-11-19

### Added

- normalizeFragment function
- denormalizeFragment function

## [0.0.2] - 2019-11-18

### Added

- Optionally add typenames when denormalizing

## [0.0.1] - 2019-11-14

### Added

- Initial normalize and denormalize implementations 🚀
- Support for variables
- Support for fragments (definitions and inline)
- Support for Apollo-style TypePolicies
- Support for Aliases
- Support for interface & union types
- Tests (for all of the above)
