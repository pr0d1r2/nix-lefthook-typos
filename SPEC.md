# SPEC — nix-lefthook-typos

## §D — Description

nix-lefthook-typos is a Nix flake that packages the [typos](https://github.com/crate-ci/typos) spell checker as a lefthook-compatible git hook command. It wraps `typos` in a shell script (`lefthook-typos`) that filters out non-existent files from the staged/pushed file list, exits cleanly when no files remain, and delegates to `typos` for actual spell checking. The project targets Nix-based development environments on Linux and macOS (amd64/arm64) and can be consumed either as a lefthook remote (zero flake config) or as a direct flake input added to a project's devShell.

## §V — Invariants

1. `lefthook-typos` exits 0 when called with no arguments.
2. `lefthook-typos` exits 0 when all arguments are non-existent files.
3. `lefthook-typos` exits 0 when all existing files pass the typos check.
4. `lefthook-typos` exits non-zero when any existing file contains a typo.
5. The flake builds on all four supported systems: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
6. Every shell script has a matching bats unit test file under `tests/unit/`.
7. All lefthook checks run on both `pre-commit` (staged files) and `pre-push` (push files).
8. Every lefthook command has a timeout (default 30s, configurable via `LEFTHOOK_TYPOS_TIMEOUT`).
9. Shell scripts contain no functions; logic is in separate scripts invoked inline.
10. Nix files contain no embedded shell; shell code is extracted to `.sh` files and read with `builtins.readFile`.
11. CI runs on both Ubuntu (always) and macOS (push/dispatch only).
12. All files conform to editorconfig: UTF-8, LF line endings, 2-space indent, final newline, no trailing whitespace.
13. The dev shell installs lefthook hooks on first entry when `.git/hooks/pre-commit` is absent.

## §I — Interfaces

### CLI command

```
lefthook-typos [file ...]
```

Filters non-existent paths from the argument list and runs `typos` on the remainder. Exits 0 if no files remain after filtering.

### Nix flake outputs

| Output | Type | Description |
|---|---|---|
| `packages.<system>.default` | `writeShellApplication` | The `lefthook-typos` wrapper script with `typos` as a runtime input |
| `devShells.<system>.default` | `mkShell` | Dev shell with all tooling, bats test libs, and lefthook auto-install |
| `devShells.<system>.ci` | `mkShell` | CI-oriented shell (from `nix-dev-shell-agentic`) |

### Lefthook remote config (`lefthook-remote.yml`)

Consumers add to their `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-typos
    ref: main
    configs:
      - lefthook-remote.yml
```

This registers `typos` commands for both `pre-commit` and `pre-push`.

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `LEFTHOOK_TYPOS_TIMEOUT` | `30` | Timeout in seconds for the typos command |
| `BATS_LIB_PATH` | Set by dev shell | Path to bats support/assert libraries |

### Config files

| File | Format | Purpose |
|---|---|---|
| `lefthook.yml` | YAML | Local lefthook config with 16 remote check suites and local typos check |
| `lefthook-remote.yml` | YAML | Exported config for consumers using lefthook remotes |
| `.yamllint.yml` | YAML | yamllint config (disables line-length, truthy key check) |
| `.markdownlint.yml` | YAML | markdownlint config (disables line-length MD013) |
| `.editorconfig` | INI | Editor formatting rules |
| `config/lefthook/file_size_limits.yml` | YAML | Per-extension file size limits for the file-size-check hook |

## §T — Tasks

| status | id | goal |
|---|---|---|
| `x` | T1 | Add bats test for mixed existent and non-existent files (only non-existent skipped, existent still checked) |
| `x` | T2 | Add bats test for `dev.sh` verifying `BATS_LIB_PATH` is not overwritten when already set |
| `x` | T3 | Add bats test for symlink handling in `lefthook-typos.sh` (symlinks to files should be checked) |
| `x` | T4 | Add `flake.lock` to `.envrc` `watch_file` entries so direnv reloads on dependency updates |
| `.` | T5 | Add `dev.sh` to `.envrc` `watch_file` entries so direnv reloads on shell hook changes |
| `.` | T6 | Add `markdownlint` lefthook check for `.md` files (linter exists in config but no lefthook command) |
| `.` | T7 | Document the full list of lefthook remote checks in README.md |
| `.` | T8 | Add a `_typos.toml` config file for project-specific typos exclusions |

## §B — Bugs / Known Issues

1. **`.envrc` missing `watch_file` entries**: The `.envrc` only contains `use flake` but does not `watch_file` for `flake.nix`, `flake.lock`, `dev.sh`, or any nix modules. The `direnv` skill requires watching flake and its dependent files for change-triggered reloads. Without these, changing `dev.sh` or `flake.nix` requires a manual `direnv reload`.

2. **Symlinks pass the `-f` check but may point to deleted targets**: `lefthook-typos.sh` uses `[ -f "$f" ]` which follows symlinks. A broken symlink (target deleted) is correctly skipped, but a valid symlink to a file is included — this is correct behavior but untested.

3. **`lefthook-remote.yml` uses `lefthook-typos` command name**: The remote config assumes the consumer has `lefthook-typos` on PATH (via the flake package). If a consumer adds the remote without the flake input, the command will fail with "command not found". The local `lefthook.yml` uses bare `typos` instead, creating an asymmetry between local and remote configs.

4. **No `_typos.toml` for the project itself**: The project has no typos configuration file, meaning any false positives in the project's own files (or future files) cannot be suppressed without adding one.

5. **CI `fatal: $HOME not set`**: `dev.sh` ran `lefthook install` unconditionally; in nix build sandboxes `$HOME` is unset, causing git to abort. Fixed by guarding with `[ -n "${HOME:-}" ]`.
