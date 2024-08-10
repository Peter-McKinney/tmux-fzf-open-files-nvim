#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/check_fzf_install.sh"
source "$CURRENT_DIR/scripts/sanitize.sh"
source "$CURRENT_DIR/scripts/awk_pane_files.sh"

check_fzf

buffer_name="tmux_capture_buffer"

if [ $# -eq 0 ]; then
  # capture content visible in the current pane
  tmux capture-pane -J -b "$buffer_name"
else
  # capture all history in the current pane
  tmux capture-pane -J -S - -E - -b "$buffer_name"
fi

captured_content=$(tmux show-buffer -b "$buffer_name")

captured_files=$(parse_files "$captured_content")
#only sanitize from matching lines
files=$(sanitize_pane_output "$captured_files")

if [ -z "$files" ]; then
  echo "No files found."
else
  # remove any empty or whitespace only entries before fzf
  # sed script will match :number:number at the end of a string for
  # supporting opening files at a target row, col location
  tmux split-window -h -c "#{pane_current_path}" "echo \"$files\" |
        sed '/^[[:space:]]*$/d' |
        fzf -m |
        sed -E 's/([^:]+):([0-9]+):([0-9]+)/-c e \1 \| normal \2G\3\|/g' |
    xargs -I {} $EDITOR {}"
fi

tmux delete-buffer -b "$buffer_name"
