#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "watches flake.lock for changes" {
    run grep -q 'watch_file flake.lock' .envrc
    assert_success
}
