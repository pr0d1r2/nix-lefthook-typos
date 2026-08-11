#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    MARKDOWNLINT="$PROJECT_ROOT/.markdownlint.yml"
    LEFTHOOK="$PROJECT_ROOT/lefthook.yml"
}

@test ".markdownlint.yml exists" {
    [ -f "$MARKDOWNLINT" ]
}

@test "configures MD013 line length" {
    run grep -q 'MD013:' "$MARKDOWNLINT"
    assert_success
    run grep -q 'line_length: 300' "$MARKDOWNLINT"
    assert_success
}

@test "lefthook pre-commit has markdownlint command" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep -q 'markdownlint:'"
    assert_success
}

@test "lefthook pre-commit markdownlint uses glob *.md" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep -q 'glob: \"\\*\\.md\"'"
    assert_success
}

@test "lefthook pre-commit markdownlint uses staged_files" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'markdownlint' | grep -q '{staged_files}'"
    assert_success
}

@test "lefthook pre-commit markdownlint has timeout" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'markdownlint' | grep -q 'timeout'"
    assert_success
}

@test "lefthook pre-commit markdownlint uses LEFTHOOK_MARKDOWNLINT_TIMEOUT" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'markdownlint' | grep -q 'LEFTHOOK_MARKDOWNLINT_TIMEOUT'"
    assert_success
}

@test "lefthook pre-push has markdownlint command" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep -q 'markdownlint:'"
    assert_success
}

@test "lefthook pre-push markdownlint uses glob *.md" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep -q 'glob: \"\\*\\.md\"'"
    assert_success
}

@test "lefthook pre-push markdownlint uses push_files" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'markdownlint' | grep -q '{push_files}'"
    assert_success
}

@test "lefthook pre-push markdownlint has timeout" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'markdownlint' | grep -q 'timeout'"
    assert_success
}

@test "lefthook pre-push markdownlint uses LEFTHOOK_MARKDOWNLINT_TIMEOUT" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'markdownlint' | grep -q 'LEFTHOOK_MARKDOWNLINT_TIMEOUT'"
    assert_success
}
