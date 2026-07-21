#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
    load "${BATS_LIB_PATH}/bats-file/load.bash"

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

@test "uses packaged config outside the project directory" {
    cat > "$TEST_TEMP/standalone.md" << 'MDEOF'
# Standalone

This file is linted from a directory without a local config.
MDEOF
    cd "$TEST_TEMP"
    run lefthook-markdownlint-agentic standalone.md
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

@test "accepts fenced code blocks in list items (MD031)" {
    cat > "$TEST_TEMP/list-code.md" << 'MDEOF'
# Steps

- Step one:
  ```bash
  echo hello
  ```
- Step two
MDEOF
    run lefthook-markdownlint-agentic "$TEST_TEMP/list-code.md"
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

@test "accepts table with inconsistent column style (MD060)" {
    cat > "$TEST_TEMP/table-style.md" << 'MDEOF'
# Data

| Name  | Value |
| ----- | ----- |
| Alice | 1     |
|Bob|2|
MDEOF
    run lefthook-markdownlint-agentic "$TEST_TEMP/table-style.md"
    assert_success
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

@test "fails for mixed valid and invalid markdown files" {
    cat > "$TEST_TEMP/good.md" << 'MDEOF'
# Hello

This is valid markdown.
MDEOF
    cat > "$TEST_TEMP/bad.md" << 'MDEOF'
# Hello
text without blank line after heading
MDEOF
    run lefthook-markdownlint-agentic "$TEST_TEMP/good.md" "$TEST_TEMP/bad.md"
    assert_failure
    assert_output --partial "bad.md"
}

@test "fails for mixed valid/invalid markdown with non-.md and missing files" {
    cat > "$TEST_TEMP/good.md" << 'MDEOF'
# Hello

This is valid markdown.
MDEOF
    cat > "$TEST_TEMP/bad.md" << 'MDEOF'
# Hello
text without blank line after heading
MDEOF
    touch "$TEST_TEMP/file.txt"
    run lefthook-markdownlint-agentic \
        "$TEST_TEMP/good.md" \
        "$TEST_TEMP/bad.md" \
        "$TEST_TEMP/file.txt" \
        "$TEST_TEMP/nonexistent.md"
    assert_failure
    assert_output --partial "bad.md"
    refute_output --partial "file.txt"
    refute_output --partial "nonexistent.md"
}

@test "non-disabled rules still produce failures" {
    cat > "$TEST_TEMP/multi-blank.md" << 'MDEOF'
# Heading

Content here.


Extra blank line above violates MD012.
MDEOF
    run lefthook-markdownlint-agentic "$TEST_TEMP/multi-blank.md"
    assert_failure
    assert_output --partial "MD012"
}

@test "succeeds for multiple valid markdown files" {
    cat > "$TEST_TEMP/one.md" << 'MDEOF'
# First

Content here.
MDEOF
    cat > "$TEST_TEMP/two.md" << 'MDEOF'
# Second

More content.
MDEOF
    run lefthook-markdownlint-agentic "$TEST_TEMP/one.md" "$TEST_TEMP/two.md"
    assert_success
}

@test "accepts a 437-char line (within 500 limit)" {
    {
        echo '# Test'
        echo ''
        python3 -c "print('a' * 436 + ' x')"
    } > "$TEST_TEMP/long437.md"
    run lefthook-markdownlint-agentic "$TEST_TEMP/long437.md"
    assert_success
}

@test "accepts a 500-char line (at boundary)" {
    {
        echo '# Test'
        echo ''
        python3 -c "print('a' * 499 + 'x')"
    } > "$TEST_TEMP/long500.md"
    run lefthook-markdownlint-agentic "$TEST_TEMP/long500.md"
    assert_success
}

@test "rejects a line exceeding 500 chars (MD013)" {
    {
        echo '# Test'
        echo ''
        python3 -c "print('a' * 500 + ' word')"
    } > "$TEST_TEMP/long505.md"
    run lefthook-markdownlint-agentic "$TEST_TEMP/long505.md"
    assert_failure
    assert_output --partial "MD013"
}
