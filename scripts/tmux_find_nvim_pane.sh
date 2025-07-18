#!/usr/bin/env bash

# find_nvim_pane() {
#   pane_ids=$(tmux list-panes -F '#{pane_id} #{pane_current_command}')
#   nvim_pane=$(echo "$pane_ids" | grep "nvim")
#   nvim_pane_id=${nvim_pane%% *}
#   echo "$nvim_pane_id"
# }

find_nvim_pane() {
  current_session=$(tmux display-message -p '#S')
  search_across_windows=$(tmux show-option -gqv @tmux-open-file-nvim-search-all-windows)
  
  if [[ "$search_across_windows" == "on" ]]; then
    # search across all windows in current session
    pane_info=$(tmux list-panes -a -F '#{session_name} #{window_id} #{pane_id} #{pane_current_command}' | grep "^$current_session " | grep "nvim")
    if [[ -n "$pane_info" ]]; then
      window_id=$(echo "$pane_info" | awk '{print $2}')
      pane_id=$(echo "$pane_info" | awk '{print $3}')
      echo "$window_id $pane_id"
    fi
  else
    # search only in current window
    pane_info=$(tmux list-panes -F '#{window_id} #{pane_id} #{pane_current_command}' | grep "nvim")
    if [[ -n "$pane_info" ]]; then
      window_id=$(echo "$pane_info" | awk '{print $1}')
      pane_id=$(echo "$pane_info" | awk '{print $2}')
      echo "$window_id $pane_id"
    fi
  fi
}
