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

@test "mixed existent and non-existent: clean existent file passes" {
    printf 'This is correct text.\n' > "$TMP/clean.txt"
    run lefthook-typos /nonexistent/file.txt "$TMP/clean.txt"
    assert_success
}

@test "mixed existent and non-existent: existent file with typos fails" {
    typo="spel""ing"
    printf 'This has a %s error.\n' "$typo" > "$TMP/typo.txt"
    run lefthook-typos /nonexistent/file.txt "$TMP/typo.txt"
    assert_failure
}

@test "symlink to clean file is checked and passes" {
    printf 'This is correct text.\n' > "$TMP/clean.txt"
    ln -s "$TMP/clean.txt" "$TMP/link_clean.txt"
    run lefthook-typos "$TMP/link_clean.txt"
    assert_success
}

@test "symlink to file with typos is checked and fails" {
    typo="spel""ing"
    printf 'This has a %s error.\n' "$typo" > "$TMP/typo.txt"
    ln -s "$TMP/typo.txt" "$TMP/link_typo.txt"
    run lefthook-typos "$TMP/link_typo.txt"
    assert_failure
}

@test "broken symlink is skipped" {
    printf 'placeholder\n' > "$TMP/target.txt"
    ln -s "$TMP/target.txt" "$TMP/link_broken.txt"
    rm "$TMP/target.txt"
    run lefthook-typos "$TMP/link_broken.txt"
    assert_success
}
