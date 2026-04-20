#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
}

@test "no args exits 0" {
    run lefthook-typos
    assert_success
}

@test "non-existent file is skipped" {
    run lefthook-typos /nonexistent/file.txt
    assert_success
}

@test "file with no typos passes" {
    cat > "$TMP/clean.txt" <<'EOF'
This is a clean file with no spelling mistakes.
EOF
    run lefthook-typos "$TMP/clean.txt"
    assert_success
}

@test "file with typos fails" {
    typo="spel""ing"
    printf 'This file has a %s mistake.\n' "$typo" > "$TMP/typo.txt"
    run lefthook-typos "$TMP/typo.txt"
    assert_failure
}

@test "multiple files: one with typos causes failure" {
    typo="spel""ing"
    printf 'This is correct text.\n' > "$TMP/clean.txt"
    printf 'This has a %s error.\n' "$typo" > "$TMP/typo.txt"
    run lefthook-typos "$TMP/clean.txt" "$TMP/typo.txt"
    assert_failure
}
