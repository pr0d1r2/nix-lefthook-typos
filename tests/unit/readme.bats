#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    README="$PROJECT_ROOT/README.md"
    LEFTHOOK="$PROJECT_ROOT/lefthook.yml"
}

@test "README.md has lefthook checks section" {
    run grep -q '## Lefthook checks' "$README"
    assert_success
}

@test "README documents nix-lefthook-nixfmt remote" {
    run grep -q 'nix-lefthook-nixfmt' "$README"
    assert_success
}

@test "README documents nix-lefthook-shellcheck remote" {
    run grep -q 'nix-lefthook-shellcheck' "$README"
    assert_success
}

@test "README documents nix-lefthook-shfmt remote" {
    run grep -q 'nix-lefthook-shfmt' "$README"
    assert_success
}

@test "README documents nix-lefthook-statix remote" {
    run grep -q 'nix-lefthook-statix' "$README"
    assert_success
}

@test "README documents nix-lefthook-deadnix remote" {
    run grep -q 'nix-lefthook-deadnix' "$README"
    assert_success
}

@test "README documents nix-lefthook-nix-no-embedded-shell remote" {
    run grep -q 'nix-lefthook-nix-no-embedded-shell' "$README"
    assert_success
}

@test "README documents nix-lefthook-bats-parse remote" {
    run grep -q 'nix-lefthook-bats-parse' "$README"
    assert_success
}

@test "README documents nix-lefthook-tdd-order-bats remote" {
    run grep -q 'nix-lefthook-tdd-order-bats' "$README"
    assert_success
}

@test "README documents nix-lefthook-yamllint remote" {
    run grep -q 'nix-lefthook-yamllint' "$README"
    assert_success
}

@test "README documents nix-lefthook-nix-flake-check remote" {
    run grep -q 'nix-lefthook-nix-flake-check' "$README"
    assert_success
}

@test "README documents nix-lefthook-trailing-whitespace remote" {
    run grep -q 'nix-lefthook-trailing-whitespace' "$README"
    assert_success
}

@test "README documents nix-lefthook-missing-final-newline remote" {
    run grep -q 'nix-lefthook-missing-final-newline' "$README"
    assert_success
}

@test "README documents nix-lefthook-git-conflict-markers remote" {
    run grep -q 'nix-lefthook-git-conflict-markers' "$README"
    assert_success
}

@test "README documents nix-lefthook-editorconfig-checker remote" {
    run grep -q 'nix-lefthook-editorconfig-checker' "$README"
    assert_success
}

@test "README documents nix-lefthook-git-no-local-paths remote" {
    run grep -q 'nix-lefthook-git-no-local-paths' "$README"
    assert_success
}

@test "README documents nix-lefthook-file-size-check remote" {
    run grep -q 'nix-lefthook-file-size-check' "$README"
    assert_success
}

@test "README documents typos local command" {
    run bash -c "sed -n '/## Lefthook checks/,\$p' '$README' | grep -q 'typos'"
    assert_success
}

@test "README documents markdownlint local command" {
    run bash -c "sed -n '/## Lefthook checks/,\$p' '$README' | grep -q 'markdownlint'"
    assert_success
}

@test "all lefthook.yml remotes are documented in README" {
    run bash -c "grep 'git_url:' '$LEFTHOOK' | sed 's|.*pr0d1r2/||' | while read -r name; do grep -q \"\$name\" '$README' || { echo \"missing: \$name\"; exit 1; }; done"
    assert_success
}
