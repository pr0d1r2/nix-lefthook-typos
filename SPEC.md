# SPEC — nix-lefthook-typos

## §D — Description

nix-lefthook-typos is a Nix flake packaging the [typos](https://github.com/crate-ci/typos) spell checker as a lefthook-compatible command.
It wraps `typos` in `lefthook-typos`, filtering missing staged/pushed files, exiting cleanly when none remain, and delegating to `typos`.
The project targets Nix-based environments on Linux and macOS (amd64/arm64), and can be used as a lefthook remote or direct flake input.

## §V — Invariants

1. `lefthook-typos` exits 0 when called with no arguments.
2. `lefthook-typos` exits 0 when all arguments are missing files.
3. `lefthook-typos` exits 0 when all existing files pass the typos check.
4. `lefthook-typos` exits non-zero when any existing file contains a typo.
5. The flake builds on: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
6. Every shell script has a matching bats test under `tests/unit/`.
7. All lefthook checks run on both `pre-commit` (staged) and `pre-push` (push) files.
8. Every lefthook command has a timeout (default 30s, configurable via `LEFTHOOK_TYPOS_TIMEOUT`).
9. Shell scripts contain no functions; logic is in separate scripts invoked inline.
10. Nix files contain no embedded shell; shell code is extracted to `.sh` files and read with `builtins.readFile`.
11. CI runs on both Ubuntu (always) and macOS (push/dispatch only).
12. All files conform to editorconfig: UTF-8, LF line endings, 2-space indent, final newline, no trailing whitespace.
13. The dev shell installs lefthook hooks on first entry when the pre-commit hook is absent.

## §I — Interfaces

### CLI command

```text
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
| `LEFTHOOK_TAPLO_TIMEOUT` | `30` | Timeout in seconds for the taplo command |
| `BATS_LIB_PATH` | Set by dev shell | Path to bats support/assert libraries |

### Config files

| File | Format | Purpose |
|---|---|---|
| `lefthook.yml` | YAML | Local lefthook config with 16 remote check suites and local typos, markdownlint, taplo checks |
| `lefthook-remote.yml` | YAML | Exported config for consumers using lefthook remotes |
| `.yamllint.yml` | YAML | yamllint config (disables line-length, truthy key check) |
| `.markdownlint.yml` | YAML | markdownlint config (disables line-length MD013) |
| `.editorconfig` | INI | Editor formatting rules |
| `_typos.toml` | TOML | Project-specific typos exclusions (extend-words) |
| `config/lefthook/file_size_limits.yml` | YAML | Per-extension file size limits for the file-size-check hook |

## §T — Tasks

| status | id | goal |
|---|---|---|
| `x` | T1 | Add bats test for mixed existent and non-existent files (only non-existent skipped, existent still checked) |
| `x` | T2 | Add bats test for `dev.sh` verifying `BATS_LIB_PATH` is not overwritten when already set |
| `x` | T3 | Add bats test for symlink handling in `lefthook-typos.sh` (symlinks to files should be checked) |
| `x` | T4 | Add `flake.lock` to `.envrc` `watch_file` entries so direnv reloads on dependency updates |
| `x` | T5 | Add `dev.sh` to `.envrc` `watch_file` entries so direnv reloads on shell hook changes |
| `x` | T6 | Add `markdownlint` lefthook check for `.md` files (linter exists in config but no lefthook command) |
| `x` | T7 | Document the full list of lefthook remote checks in README.md |
| `x` | T8 | Add a `_typos.toml` config file for project-specific typos exclusions |

## §B — Bugs / Known Issues

1. **`.envrc` missing `watch_file` entries**: The `.envrc` only contains `use flake`; changing `dev.sh` or `flake.nix` therefore requires a manual `direnv reload`.

2. **Symlink handling is untested**: `lefthook-typos.sh` uses `[ -f "$f" ]`, so valid symlinks are included and broken ones skipped.

3. **Remote command availability**: `lefthook-remote.yml` assumes the flake package puts `lefthook-typos` on PATH; without the input it fails. The local config uses bare `typos`.

4. **No `_typos.toml` for the project itself**: The project has no typos configuration file, meaning any false positives in the project's own files (or future files) cannot be suppressed without adding one.

5. **CI `fatal: $HOME not set`**: `dev.sh` ran `lefthook install` unconditionally; in Nix sandboxes `$HOME` is unset, so git aborts. Fixed by guarding with `[ -n "${HOME:-}" ]`.

6. **CI `markdownlint: No such file or directory`**: `lefthook.yml` referenced `markdownlint`, but it was missing from both devShells. Fixed by adding `pkgs.markdownlint-cli` to `ciPackages`.

7. **CI `lefthook-markdownlint-agentic: No such file or directory`**: `lefthook.yml` referenced this command, but the pinned `nix-dev-shell-agentic` does not provide it (exit 127).
    Fixed by adding `nix-lefthook-markdownlint-agentic`; `mkShells` includes `nix-lefthook-*` inputs, putting its package on `PATH`.

8. **CI `markdownlint MD013/line-length` on `SPEC.md`**: CI runs `lefthook run pre-commit --all-files`, so `markdownlint` lints `SPEC.md` under `.markdownlint.yml` (line length 300). Several prose lines exceeded 300 characters.
    Fixed by reflowing the over-long `§D` paragraph and `§B` entries to stay within the limit; no linter rule was relaxed.

9. **CI coherence wrappers missing from the confirm app PATH**: The `confirm` app assembled hooks but its `runtimeInputs` lacked `lefthook-markdownlint`, `lefthook-markdownlint-agentic`, and `lefthook-yamllint`.
    Fixed by adding fragment packages to the app runtime and removing redundant wrapper inputs.

10. **Pin refresh made `flake.lock` exceed the file-size guardrail**: Independent recursive `nixpkgs-lock` and `set-and-setting` inputs duplicated the transitive flake graph, growing the lockfile to 120,413 bytes.
    Fixed by pinning `nixpkgs` directly and making both compatibility inputs of `set-and-setting` follow it, reducing the lock graph without relaxing the 65,536-byte limit.

11. **CI flake manifest rejected `let` outputs**: Fixed with `set-and-setting.lib.mkConsumerFlake`.

12. **Guardrails rejected the lock graph and lefthook fidelity**: The consumer flake omitted the required explicit `nixpkgs-lock` node and did not select the `toml` fragment despite its repo-local Taplo hook. Fixed by adding the shared lock input with `follows` and including the `toml` fragment.

13. **CI Bats could not find `lefthook-typos`**: The executable was exposed only as the default package, but the consumer dev shell used by the guardrail suite does not add that package to `PATH`. Fixed by exposing it under its executable name through `extraPackages`.

14. **Template flake description**: `CHANGEME` failed metadata validation. Fixed with a project-specific description.

15. **Guardrail Bats tools missing from the consumer devShell**: The CI suite
    invokes `lefthook-typos` and `taplo` directly, but `extraPackages` only
    exposed the former as a flake package and the standard materialization only
    exposed the latter through its wrapper. Fixed by adding both executables to
    every consumer devShell.
