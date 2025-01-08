#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/check_fzf_install.sh"
source "$CURRENT_DIR/scripts/tmux_find_nvim_pane.sh"
source "$CURRENT_DIR/scripts/file_strings_to_nvim.sh"

check_fzf

editor_files=$(source "$CURRENT_DIR/utilities/fzf-files.sh" "$1")

if [[ -z "$editor_files" ]]; then
  echo "No files found or selected through fzf"
else
  nvim_pane_id=$(find_nvim_pane)

  if [[ -z "$nvim_pane_id" ]]; then
    # create a new neovim pane in tmux
    nvim_pane_id=$(tmux split-window -h -c "#{pane_current_path}")
    tmux send-keys -t "$nvim_pane_id" "nvim" Enter
  fi

  nvim_command="$(to_tabedit_strings "$editor_files")"
  tmux send-keys -t "$nvim_pane_id" Escape ":$nvim_command" Enter
  tmux select-pane -t "$nvim_pane_id"
fi
