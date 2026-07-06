#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    LEFTHOOK="$PROJECT_ROOT/lefthook.yml"
}

@test "lefthook pre-commit has taplo command" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep -q 'taplo:'"
    assert_success
}

@test "lefthook pre-commit taplo uses glob *.toml" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep -q 'glob: \"\\*\\.toml\"'"
    assert_success
}

@test "lefthook pre-commit taplo uses staged_files" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'taplo' | grep -q '{staged_files}'"
    assert_success
}

@test "lefthook pre-commit taplo has timeout" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'taplo' | grep -q 'timeout'"
    assert_success
}

@test "lefthook pre-commit taplo uses LEFTHOOK_TAPLO_TIMEOUT" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'taplo' | grep -q 'LEFTHOOK_TAPLO_TIMEOUT'"
    assert_success
}

@test "lefthook pre-push has taplo command" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep -q 'taplo:'"
    assert_success
}

@test "lefthook pre-push taplo uses glob *.toml" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep -q 'glob: \"\\*\\.toml\"'"
    assert_success
}

@test "lefthook pre-push taplo uses push_files" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'taplo' | grep -q '{push_files}'"
    assert_success
}

@test "lefthook pre-push taplo has timeout" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'taplo' | grep -q 'timeout'"
    assert_success
}

@test "lefthook pre-push taplo uses LEFTHOOK_TAPLO_TIMEOUT" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'taplo' | grep -q 'LEFTHOOK_TAPLO_TIMEOUT'"
    assert_success
}
