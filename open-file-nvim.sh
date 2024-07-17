#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/check_fzf_install.sh"
source "$CURRENT_DIR/scripts/sanitize.sh"
source "$CURRENT_DIR/scripts/awk_pane_files.sh"

check_fzf

buffer_name="tmux_capture_buffer"

if [ $# -eq 0 ]; then
    tmux capture-pane -J -b "$buffer_name"
else
    tmux capture-pane -J -S - -E - -b "$buffer_name"
fi

captured_content=$(tmux show-buffer -b "$buffer_name")
sanitized_content=$(sanitize_pane_output "$captured_content")
files=$(parse_files "$sanitized_content")

if [ -z "$files" ]; then
    echo "No files found."
else
    tmux split-window -h -c "#{pane_current_path}" "echo \"$files\" | fzf -m | xargs -I {} $EDITOR {}"
fi

tmux delete-buffer -b "$buffer_name"
