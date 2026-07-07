#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "pre-commit references LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT" {
    run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep -q "LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT"'
    assert_success
}

@test "pre-push references LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT" {
    run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep -q "LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT"'
    assert_success
}

@test "pre-commit timeout defaults to 30" {
    run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep -o "LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT:-[0-9]*"'
    assert_success
    assert_output "LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT:-30"
}

@test "pre-push timeout defaults to 30" {
    run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep -o "LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT:-[0-9]*"'
    assert_success
    assert_output "LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT:-30"
}

@test "timeout expansion defaults to 30 when env var is unset" {
    run bash -c 'unset LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT; echo "${LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT:-30}"'
    assert_success
    assert_output "30"
}

@test "timeout expansion uses custom value when env var is set" {
    export LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT=60
    run bash -c 'echo "${LEFTHOOK_MARKDOWNLINT_AGENTIC_TIMEOUT:-30}"'
    assert_success
    assert_output "60"
}
