#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/../scripts/check_fzf_install.sh"
source "$CURRENT_DIR/../scripts/sanitize.sh"
source "$CURRENT_DIR/../scripts/awk_pane_files.sh"

parse() {
  captured_content=$(tmux show-buffer -b "$buffer_name")

  captured_files=$(parse_files "$captured_content")
  #only sanitize from matching lines
  files=$(sanitize_pane_output "$captured_files")

  echo "$files"
}

buffer_name="fzf-files-buffer"
temp_buffer="fzf-files-temp-buffer"
files=()

if [ "$1" = "--selected-pane-history" ]; then
  # capture all history in the current pane
  tmux capture-pane -J -S - -E - -b "$buffer_name"
  files=("$(parse)")
elif [ "$1" = "--all-pane-history" ]; then
  # capture each pane history in the current window
  panes=$(tmux list-panes -F '#{pane_id} #{pane_current_command} #{pane_current_path}')

  while IFS= read -r pane; do
    pane_id=$(echo "$pane" | awk '{print $1}')

    tmux capture-pane -t "$pane_id" -J -S - -E - -b "$temp_buffer"
    pane_output=$(tmux save-buffer -b "$temp_buffer" -)

    tmux set-buffer -b "$buffer_name" -a "$pane_output"
  done <<<"$panes"

  files+=("$(parse)")
else
  # capture content visible in the current pane
  tmux capture-pane -J -b "$buffer_name"
  files=("$(parse)")
fi

# TODO: figure out a way to remove this duplicated call
# calling parse files again to remove duplicates
unique_files=$(parse_files "${files[@]}")

if [ -z "$unique_files" ]; then
  echo ""
else
  tmpfile=$(mktemp)

  tmux display-popup -E "echo \"$unique_files\" | sed '/^[[:space:]]*$/d' | fzf -m > $tmpfile"

  selected_files=$(cat "$tmpfile")
  rm "$tmpfile"

  echo "$selected_files"
fi
