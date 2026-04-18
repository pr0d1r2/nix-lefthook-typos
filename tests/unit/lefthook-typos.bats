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
    cat > "$TMP/typo.txt" <<'EOF'
This file has a speling mistake.
EOF
    run lefthook-typos "$TMP/typo.txt"
    assert_failure
}

@test "multiple files: one with typos causes failure" {
    cat > "$TMP/clean.txt" <<'EOF'
This is correct text.
EOF
    cat > "$TMP/typo.txt" <<'EOF'
This has a speling error.
EOF
    run lefthook-typos "$TMP/clean.txt" "$TMP/typo.txt"
    assert_failure
}
