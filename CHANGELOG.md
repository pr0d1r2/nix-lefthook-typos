# Changelog

All notable changes to this project are documented here.

## Unreleased

### Fixed

- Drop the repo-local `lefthook-repo.yml` carried over from the vendored
  config. Its bare `taplo format --check` duplicated the standard's `taplo`
  command (`lefthook-taplo`, from the declared `toml` fragment); the
  assembler already discarded it as a duplicate key, so it was dead config.
