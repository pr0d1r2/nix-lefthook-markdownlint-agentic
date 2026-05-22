#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"
    load "$BATS_LIB_PATH/bats-file/load"
}

@test "lefthook-markdownlint-agentic is on PATH" {
    run which lefthook-markdownlint-agentic
    assert_success
}
