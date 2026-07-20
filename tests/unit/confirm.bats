#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMPDIR="$(mktemp -d)"

    cat > "$TMPDIR/mock-confirm.sh" <<'SH'
#!/usr/bin/env bash
echo "FRAGMENTS_DIR=$FRAGMENTS_DIR"
echo "ASSEMBLE_SCRIPT=$ASSEMBLE_SCRIPT"
echo "DETECT_SCRIPT=$DETECT_SCRIPT"
echo "SETTING_SRC=$SETTING_SRC"
echo "CONFIRM_SCRIPT=$CONFIRM_SCRIPT"
echo "CONFIRM_REV=$CONFIRM_REV"
SH
    chmod +x "$TMPDIR/mock-confirm.sh"
}

teardown() {
    rm -rf "$TMPDIR"
}

@test "exports all six environment variables" {
    run bash confirm.sh \
        "/fragments" \
        "/assemble" \
        "/detect" \
        "/setting" \
        "$TMPDIR/mock-confirm.sh" \
        "abc123"
    assert_success
    assert_line "FRAGMENTS_DIR=/fragments"
    assert_line "ASSEMBLE_SCRIPT=/assemble"
    assert_line "DETECT_SCRIPT=/detect"
    assert_line "SETTING_SRC=/setting"
    assert_line "CONFIRM_SCRIPT=$TMPDIR/mock-confirm.sh"
    assert_line "CONFIRM_REV=abc123"
}

@test "calls CONFIRM_SCRIPT via bash" {
    run bash confirm.sh \
        "/a" "/b" "/c" "/d" \
        "$TMPDIR/mock-confirm.sh" \
        "rev1"
    assert_success
    assert_output --partial "CONFIRM_REV=rev1"
}

@test "exits non-zero when CONFIRM_SCRIPT fails" {
    cat > "$TMPDIR/fail-confirm.sh" <<'SH'
#!/usr/bin/env bash
exit 1
SH
    chmod +x "$TMPDIR/fail-confirm.sh"
    run bash confirm.sh \
        "/a" "/b" "/c" "/d" \
        "$TMPDIR/fail-confirm.sh" \
        "rev1"
    assert_failure
}
