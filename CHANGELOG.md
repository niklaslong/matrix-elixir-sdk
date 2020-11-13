# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

* doc: start tracking a changelog [#91]

[#91]: https://github.com/niklaslong/matrix-elixir-sdk/pull/91

### Changed

* refactor: rename `Client` -> `API` [#89]

[#89]: https://github.com/niklaslong/matrix-elixir-sdk/pull/89

## [0.2.0]

* the `Client` module no longer wraps the `Request` module but is to be used in conjunction with the latter.
* new endpoints added (including but not limited to: content uploading/downloading, room aliases and read markers).
* added the examples directory.

## [0.1.0]

First version of the Client-Server API wrapper.

[unreleased]: https://github.com/niklaslong/matrix-elixir-sdk/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/niklaslong/matrix-elixir-sdk/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/niklaslong/matrix-elixir-sdk/releases/tag/v0.1.0
