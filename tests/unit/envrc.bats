#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TEST_TMPDIR="$(mktemp -d)"
    WATCH_LOG="$TEST_TMPDIR/watch_log"
    export WATCH_LOG

    cp .envrc "$TEST_TMPDIR/envrc"

    mkdir -p "$TEST_TMPDIR/bin"
    cat > "$TEST_TMPDIR/bin/watch_file" <<'SH'
#!/usr/bin/env bash
echo "$1" >> "$WATCH_LOG"
SH
    chmod +x "$TEST_TMPDIR/bin/watch_file"
    cat > "$TEST_TMPDIR/bin/use" <<'SH'
#!/usr/bin/env bash
:
SH
    chmod +x "$TMPDIR/bin/use"
}

teardown() {
    rm -rf "$TEST_TMPDIR"
}

@test "watches flake.nix for changes" {
    # shellcheck disable=SC2030
    export PATH="$TEST_TMPDIR/bin:$PATH"
    # shellcheck disable=SC1091
    source "$TEST_TMPDIR/envrc"
    run grep -q "flake.nix" "$WATCH_LOG"
    assert_success
}

@test "watches flake.lock for changes" {
    # shellcheck disable=SC2030,SC2031
    export PATH="$TEST_TMPDIR/bin:$PATH"
    # shellcheck disable=SC1091
    source "$TEST_TMPDIR/envrc"
    run grep -q "flake.lock" "$WATCH_LOG"
    assert_success
}

@test "watches dev.sh for changes" {
    # shellcheck disable=SC2030,SC2031
    export PATH="$TEST_TMPDIR/bin:$PATH"
    # shellcheck disable=SC1091
    source "$TEST_TMPDIR/envrc"
    run grep -q "dev.sh" "$WATCH_LOG"
    assert_success
}

@test "watches confirm.sh for changes" {
    # shellcheck disable=SC2030,SC2031
    export PATH="$TEST_TMPDIR/bin:$PATH"
    # shellcheck disable=SC1091
    source "$TEST_TMPDIR/envrc"
    run grep -q "confirm.sh" "$WATCH_LOG"
    assert_success
}

@test "watches lefthook-markdownlint-agentic.sh for changes" {
    # shellcheck disable=SC2030,SC2031
    export PATH="$TEST_TMPDIR/bin:$PATH"
    # shellcheck disable=SC1091
    source "$TEST_TMPDIR/envrc"
    run grep -q "lefthook-markdownlint-agentic.sh" "$WATCH_LOG"
    assert_success
}

@test "watches is-markdown-agentic.sh for changes" {
    # shellcheck disable=SC2030,SC2031
    export PATH="$TEST_TMPDIR/bin:$PATH"
    # shellcheck disable=SC1091
    source "$TEST_TMPDIR/envrc"
    run grep -q "is-markdown-agentic.sh" "$WATCH_LOG"
    assert_success
}

@test "watches .markdownlint-agentic.yml for changes" {
    # shellcheck disable=SC2030,SC2031
    export PATH="$TEST_TMPDIR/bin:$PATH"
    # shellcheck disable=SC1091
    source "$TEST_TMPDIR/envrc"
    run grep -q ".markdownlint-agentic.yml" "$WATCH_LOG"
    assert_success
}
