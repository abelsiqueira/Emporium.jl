# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [unreleased]

...

## [0.2.4] - 2023-07-23

### Changed

- Allow customized commit message, PR title, and PR body for compliance update.
- If an existing compliance update with the same content exists, don't create a new one.

## [0.2.3] - 2023-07-18

### Fixed

- Fixed the printed url when creating a pull request

## [0.2.2] - 2023-01-15

### Fixed

- Fix authentication on `check_and_fix_compliance` push.

## [0.2.1] - 2023-01-15

### Added

- `check_and_fix_compliance` to compare a list of files in a folder of packages against a template package.

### Changed

- `create_pull_request` now returns a `PullRequest` object. If `dry-run = true`, it returns an empty one, otherwise the created PR.
- Add option `rethrow_exception` to `run_on_folder` to allow propagating the exception.

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
[unreleased]: https://github.com/abelsiqueira/Emporium.jl/compare/v0.2.4...HEAD
[0.2.4]: https://github.com/abelsiqueira/Emporium.jl/compare/v0.2.3..v0.2.4
[0.2.3]: https://github.com/abelsiqueira/Emporium.jl/compare/v0.2.2..v0.2.3
[0.2.2]: https://github.com/abelsiqueira/Emporium.jl/compare/v0.2.1..v0.2.2
[0.2.1]: https://github.com/abelsiqueira/Emporium.jl/compare/v0.2.0..v0.2.1
[0.2.0]: https://github.com/abelsiqueira/Emporium.jl/compare/v0.1.0..v0.2.0
[0.1.0]: https://github.com/abelsiqueira/Emporium.jl/releases/tag/v0.1.0
