#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    CONFIG="config/lefthook/file_size_limits.yml"
}

@test "has md extension limit" {
    run grep -E "^\s+md:" "$CONFIG"
    assert_success
}

@test "has sh extension limit" {
    run grep -E "^\s+sh:" "$CONFIG"
    assert_success
}

@test "has nix extension limit" {
    run grep -E "^\s+nix:" "$CONFIG"
    assert_success
}

@test "has bats extension limit" {
    run grep -E "^\s+bats:" "$CONFIG"
    assert_success
}

@test "has yml extension limit" {
    run grep -E "^\s+yml:" "$CONFIG"
    assert_success
}

@test "has lock extension limit" {
    run grep -E "^\s+lock:" "$CONFIG"
    assert_success
}

@test "has default limit" {
    run grep -E "^default:" "$CONFIG"
    assert_success
}
