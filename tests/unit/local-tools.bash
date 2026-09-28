# shellcheck shell=bash
# Put THIS repository's tools on PATH, built from its own sources the way
# nix/packages.nix builds them (writeShellApplication adds the strict-mode
# header; the wrapper gets its config path substituted). The dev shell comes
# from the set-and-setting standard and carries the RELEASED tools, so a spec
# that reached for PATH would test the release, not the change under review.
#
# Loaded from each spec's setup(); LOCAL_TOOLS is removed in teardown().

LOCAL_TOOLS_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
LOCAL_TOOLS="$(mktemp -d)"
{
  printf '#!/usr/bin/env bash\nset -euo pipefail\n'
  cat "$LOCAL_TOOLS_ROOT/is-markdown-agentic.sh"
} >"$LOCAL_TOOLS/is-markdown-agentic"
{
  printf '#!/usr/bin/env bash\nset -euo pipefail\n'
  sed "s|@MARKDOWNLINT_AGENTIC_CONFIG@|$LOCAL_TOOLS_ROOT/.markdownlint-agentic.yml|g" \
    "$LOCAL_TOOLS_ROOT/lefthook-markdownlint-agentic.sh"
} >"$LOCAL_TOOLS/lefthook-markdownlint-agentic"
chmod +x "$LOCAL_TOOLS/is-markdown-agentic" "$LOCAL_TOOLS/lefthook-markdownlint-agentic"
PATH="$LOCAL_TOOLS:$PATH"
export PATH LOCAL_TOOLS
