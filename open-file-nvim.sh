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
  nvim_info=$(find_nvim_pane)

  if [[ -z "$nvim_info" ]]; then
    # create a new neovim pane in tmux
    nvim_pane_id=$(tmux split-window -h -c "#{pane_current_path}")
    tmux send-keys -t "$nvim_pane_id" "nvim" Enter
  else
    # extract window and pane IDs
    nvim_window_id=$(echo "$nvim_info" | awk '{print $1}')
    nvim_pane_id=$(echo "$nvim_info" | awk '{print $2}')
    
    # check if searching nvim across windows is enabled (default: off)
    search_across_windows=$(tmux show-option -gqv @tmux-open-file-nvim-search-all-windows)
    if [[ "$search_across_windows" == "on" ]]; then
      # switch to the window containing neovim
      tmux select-window -t "$nvim_window_id"
    fi
  fi

  nvim_command="$(to_tabedit_strings "$editor_files")"
  tmux send-keys -t "$nvim_pane_id" Escape ":$nvim_command" Enter
  tmux select-pane -t "$nvim_pane_id"
fi
