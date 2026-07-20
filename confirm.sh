# shellcheck shell=bash
# NOTE: sourced by writeShellApplication — no shebang or set needed.

export FRAGMENTS_DIR="$1"
export ASSEMBLE_SCRIPT="$2"
export DETECT_SCRIPT="$3"
export SETTING_SRC="$4"
export CONFIRM_SCRIPT="$5"
export CONFIRM_REV="$6"
bash "$CONFIRM_SCRIPT"
