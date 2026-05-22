#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"
    load "$BATS_LIB_PATH/bats-file/load"

    TEST_TEMP="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_TEMP"
}

@test "exits 0 with no arguments" {
    run lefthook-markdownlint-agentic
    assert_success
}

@test "exits 0 when no .md files in arguments" {
    touch "$TEST_TEMP/file.txt"
    run lefthook-markdownlint-agentic "$TEST_TEMP/file.txt"
    assert_success
}

@test "skips missing files silently" {
    run lefthook-markdownlint-agentic "/nonexistent/file.md"
    assert_success
}

@test "accepts valid markdown file" {
    cat > "$TEST_TEMP/good.md" << 'MDEOF'
# Hello

This is valid markdown.
MDEOF
    run lefthook-markdownlint-agentic "$TEST_TEMP/good.md"
    assert_success
}

@test "accepts markdown without heading (agentic style)" {
    cat > "$TEST_TEMP/skill.md" << 'MDEOF'
This skill file starts with a description, not a heading.

## Details

Some details here.
MDEOF
    run lefthook-markdownlint-agentic "$TEST_TEMP/skill.md"
    assert_success
}

@test "accepts markdown with unfenced code blocks" {
    cat > "$TEST_TEMP/cmd.md" << 'MDEOF'
# Command

Some code:

```
echo hello
```
MDEOF
    run lefthook-markdownlint-agentic "$TEST_TEMP/cmd.md"
    assert_success
}

@test "detects actual markdown errors" {
    cat > "$TEST_TEMP/bad.md" << 'MDEOF'
# Hello
text without blank line after heading
MDEOF
    run lefthook-markdownlint-agentic "$TEST_TEMP/bad.md"
    assert_failure
}

@test "filters non-.md files from mixed input" {
    cat > "$TEST_TEMP/good.md" << 'MDEOF'
# Hello

This is valid markdown.
MDEOF
    touch "$TEST_TEMP/file.txt"
    run lefthook-markdownlint-agentic "$TEST_TEMP/good.md" "$TEST_TEMP/file.txt"
    assert_success
}
