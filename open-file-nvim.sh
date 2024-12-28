#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/check_fzf_install.sh"

check_fzf

editor_files=$(source "$CURRENT_DIR/utilities/fzf-files.sh" "$1")

set -x
if [[ -z "$editor_files" ]]; then
  echo "No files found or selected through fzf"
else
  source "$CURRENT_DIR/scripts/tmux_find_nvim_pane.sh"
  source "$CURRENT_DIR/scripts/file_strings_to_nvim.sh"
  nvim_pane_id=$(find_nvim_pane)

  if [[ -n "$nvim_pane_id" ]]; then
    nvim_command="$(to_tabedit_strings "$editor_files")"
    tmux send-keys -t "$nvim_pane_id" Escape ":$nvim_command" Enter
    tmux select-pane -t "$nvim_pane_id"
  else
    nvim_command=$(to_buffer_strings "$editor_files")
    echo "$nvim_command"
    # sed script will match :number:number at the end of a string for
    # supporting opening files at a target row, col location
    new_pane=$(tmux split-window -h -c "#{pane_current_path}")
    tmux send-keys -t "$new_pane" "nvim" Enter
    tmux send-keys -t "$new_pane" Escape ":$nvim_command" Enter
    tmux select-pane -t "$new_pane"
  fi
fi

set +x
