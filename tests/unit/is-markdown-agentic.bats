#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "classifies supported agentic directories" {
    run is-markdown-agentic "agent/set/skills/tdd.md"
    assert_success

    run is-markdown-agentic "/repo/.claude/skills/review.md"
    assert_success

    run is-markdown-agentic "files/commands/run.md"
    assert_success
}

@test "does not classify ordinary documentation as agentic" {
    run is-markdown-agentic "README.md"
    assert_failure

    run is-markdown-agentic "SPEC.md"
    assert_failure

    run is-markdown-agentic "docs/guide.md"
    assert_failure

    run is-markdown-agentic "agent/../README.md"
    assert_failure
}

@test "requires exactly one markdown path" {
    run is-markdown-agentic
    assert_failure

    run is-markdown-agentic "agent/one.md" "agent/two.md"
    assert_failure

    run is-markdown-agentic "agent/instructions.txt"
    assert_failure
}
