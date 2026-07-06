#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    TYPOS_CONFIG="$PROJECT_ROOT/_typos.toml"
}

@test "_typos.toml exists" {
    [ -f "$TYPOS_CONFIG" ]
}

@test "_typos.toml is valid TOML" {
    run taplo format --check "$TYPOS_CONFIG"
    assert_success
}

@test "_typos.toml has default.extend-words section" {
    run grep -q '\[default\.extend-words\]' "$TYPOS_CONFIG"
    assert_success
}
