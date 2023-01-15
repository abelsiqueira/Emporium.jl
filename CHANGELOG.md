# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [unreleased]

### Added

- `check_and_fix_compliance` to compare a list of files in a folder of packages against a template package.

### Changed

- `create_pull_request` now returns a `PullRequest` object. If `dry-run = true`, it returns an empty one, otherwise the created PR.
- Add option `rethrow_exception` to `run_on_folder` to allow propagating the exception.

### Deprecated

### Removed

### Fixed

- Added compat bounds

### Security

## [0.2.0] - 2022-03-07

### Added

- Git auxiliary function
- This CHANGELOG.md file
- Organization related functions
- Function to run on folders

## [0.1.0] - 2021-10-22

- initial release

### Added

- Package created using PkgTemplates.jl
- Function to create test/Project.toml from Project.toml
- Citation and Zenodo

<!-- Links -->
[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html

<!-- Versions -->
[unreleased]: https://github.com/abelsiqueira/Emporium.jl/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/abelsiqueira/Emporium.jl/compare/v0.1.0..v0.2.0
[0.1.0]: https://github.com/abelsiqueira/Emporium.jl/releases/tag/v0.1.0
