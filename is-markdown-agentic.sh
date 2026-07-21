# shellcheck shell=bash
# Detect whether a markdown path is in a supported agentic directory.
# Exits 0 for agentic markdown and 1 otherwise.
# NOTE: sourced by writeShellApplication — no shebang or set needed.

if [ $# -ne 1 ]; then
  exit 1
fi

# Do not let a lexical agentic prefix route a path that escapes it.
case "/$1/" in
  */../*) exit 1 ;;
esac

case "$1" in
  agent/*.md | */agent/*.md) exit 0 ;;
  .claude/*.md | */.claude/*.md) exit 0 ;;
  files/commands/*.md | */files/commands/*.md) exit 0 ;;
esac

exit 1
