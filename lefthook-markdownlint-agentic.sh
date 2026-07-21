# shellcheck shell=bash
# Lefthook-compatible markdownlint wrapper for agentic skill/command files.
# NOTE: sourced by writeShellApplication — no shebang or set needed.

if [ $# -eq 0 ]; then
  exit 0
fi

files=()
for f in "$@"; do
  [ -f "$f" ] || continue
  case "$f" in
    *.md)
      if is-markdown-agentic "$f"; then
        files+=("$f")
      fi
      ;;
  esac
done

if [ ${#files[@]} -eq 0 ]; then
  exit 0
fi

exec markdownlint --config @MARKDOWNLINT_AGENTIC_CONFIG@ -- "${files[@]}"
