#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "no remote uses ref: main" {
    run grep 'ref: main' lefthook.yml
    assert_failure
}

@test "all remote refs are pinned to commit SHAs" {
    run bash -c "grep '^\s*ref:' lefthook.yml | sed 's/.*ref:\s*//' | grep -vE '^[0-9a-f]{40}$'"
    assert_failure
}

@test "every remote has a ref field" {
    run bash -c "
        in_remote=false
        has_ref=false
        missing=0
        while IFS= read -r line; do
            if echo \"\$line\" | grep -qE '^\s*- git_url:'; then
                if \$in_remote && ! \$has_ref; then
                    missing=\$((missing + 1))
                fi
                in_remote=true
                has_ref=false
            elif echo \"\$line\" | grep -qE '^\s*ref:'; then
                has_ref=true
            fi
        done < lefthook.yml
        if \$in_remote && ! \$has_ref; then
            missing=\$((missing + 1))
        fi
        echo \"\$missing\"
    "
    assert_success
    assert_output "0"
}

@test "remote ref count matches remote count" {
    run bash -c "
        remotes=\$(grep -c 'git_url:' lefthook.yml)
        refs=\$(grep -cE '^\s+ref:' lefthook.yml)
        if [ \"\$remotes\" -eq \"\$refs\" ]; then
            echo 'match'
        else
            echo \"mismatch: \$remotes remotes vs \$refs refs\"
        fi
    "
    assert_success
    assert_output "match"
}
