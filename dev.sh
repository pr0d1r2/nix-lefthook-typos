# shellcheck shell=bash
export BATS_LIB_PATH="${BATS_LIB_PATH:-@BATS_LIB_PATH@/share/bats}"
if [ -n "${HOME:-}" ]; then
    [ -f .git/hooks/pre-commit ] || lefthook install
fi
