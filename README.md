# nix-lefthook-typos

[![CI](https://github.com/pr0d1r2/nix-lefthook-typos/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-typos/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible [typos](https://github.com/crate-ci/typos) spell checker, packaged as a Nix flake.

Catches spelling mistakes in source code and documentation. Filters non-existent files from staged arguments and runs typos on the rest. Exits 0 when no files are found.

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml` — no flake input needed, just `pkgs.typos` in your devShell:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-typos
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-typos = {
  url = "github:pr0d1r2/nix-lefthook-typos";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-typos.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Add to `lefthook.yml`:

```yaml
pre-commit:
  commands:
    typos:
      run: timeout ${LEFTHOOK_TYPOS_TIMEOUT:-30} lefthook-typos {staged_files}
```

### Configuring timeout

The default timeout is 30 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_TYPOS_TIMEOUT=60
```

## Lefthook checks

This project enforces code quality via [lefthook](https://github.com/evilmartians/lefthook) git hooks on both `pre-commit` and `pre-push`. Checks are loaded as lefthook remotes plus local commands.

### Remote checks

| Remote | Description |
|---|---|
| [nix-lefthook-nixfmt](https://github.com/pr0d1r2/nix-lefthook-nixfmt) | Nix code formatter |
| [nix-lefthook-shellcheck](https://github.com/pr0d1r2/nix-lefthook-shellcheck) | Shell script linter |
| [nix-lefthook-shfmt](https://github.com/pr0d1r2/nix-lefthook-shfmt) | Shell script formatter |
| [nix-lefthook-statix](https://github.com/pr0d1r2/nix-lefthook-statix) | Nix static analysis |
| [nix-lefthook-deadnix](https://github.com/pr0d1r2/nix-lefthook-deadnix) | Dead Nix code detection |
| [nix-lefthook-nix-no-embedded-shell](https://github.com/pr0d1r2/nix-lefthook-nix-no-embedded-shell) | No embedded shell in Nix files |
| [nix-lefthook-bats-parse](https://github.com/pr0d1r2/nix-lefthook-bats-parse) | Bats test file syntax check |
| [nix-lefthook-tdd-order-bats](https://github.com/pr0d1r2/nix-lefthook-tdd-order-bats) | TDD test ordering for bats |
| [nix-lefthook-yamllint](https://github.com/pr0d1r2/nix-lefthook-yamllint) | YAML linter |
| [nix-lefthook-nix-flake-check](https://github.com/pr0d1r2/nix-lefthook-nix-flake-check) | Nix flake evaluation check |
| [nix-lefthook-trailing-whitespace](https://github.com/pr0d1r2/nix-lefthook-trailing-whitespace) | Trailing whitespace detection |
| [nix-lefthook-missing-final-newline](https://github.com/pr0d1r2/nix-lefthook-missing-final-newline) | Missing final newline detection |
| [nix-lefthook-git-conflict-markers](https://github.com/pr0d1r2/nix-lefthook-git-conflict-markers) | Git conflict markers detection |
| [nix-lefthook-editorconfig-checker](https://github.com/pr0d1r2/nix-lefthook-editorconfig-checker) | EditorConfig compliance check |
| [nix-lefthook-git-no-local-paths](https://github.com/pr0d1r2/nix-lefthook-git-no-local-paths) | No local filesystem paths in git |
| [nix-lefthook-file-size-check](https://github.com/pr0d1r2/nix-lefthook-file-size-check) | File size limits enforcement |

### Local commands

| Command | Description |
|---|---|
| typos | Spell checker for source code and docs |
| markdownlint | Markdown style and syntax linter |

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) — entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-typos  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

## License

MIT
