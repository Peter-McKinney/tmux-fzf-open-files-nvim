#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/check_fzf_install.sh"
source "$CURRENT_DIR/scripts/tmux_find_nvim_target.sh"
source "$CURRENT_DIR/scripts/file_strings_to_nvim.sh"

check_fzf

editor_files=$(source "$CURRENT_DIR/utilities/fzf-files.sh" "$1")

if [[ -z "$editor_files" ]]; then
  echo "No files found or selected through fzf"
else
  search_across_windows=$(tmux show-option -gqv @tmux-open-file-nvim-search-all-windows)
  nvim_command="$(to_tabedit_strings "$editor_files")"

  read -r nvim_window_id nvim_pane_id <<< "$(get_nvim_pane)"
  tmux send-keys -t "$nvim_pane_id" Escape ":$nvim_command" Enter

  # check if searching nvim across windows is enabled (default: off)
  if [[ "$search_across_windows" == "on" ]]; then
    tmux select-window -t "$nvim_window_id"
  fi
  tmux select-pane -t "$nvim_pane_id"
fi
