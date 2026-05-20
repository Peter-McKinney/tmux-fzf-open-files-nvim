#!/usr/bin/env bash

create_nvim_pane() {
  nvim_pane_id=$(tmux split-window -h -c "#{pane_current_path}")
  tmux send-keys -t "$nvim_pane_id" "nvim" Enter

  echo "$nvim_pane_id"
}

get_nvim_pane() {
  nvim_info=$(find_nvim_target)

  if [[ -z "$nvim_info" ]]; then
    create_nvim_pane
  else
    echo "$nvim_info"
  fi
}

extract_pane_info() {
  local pane_info="$1"
  local window_col="$2"
  local pane_col="$3"

  if [[ -n "$pane_info" ]]; then
    window_id=$(echo "$pane_info" | awk -v col="$window_col" '{print $col}')
    pane_id=$(echo "$pane_info" | awk -v col="$pane_col" '{print $col}')
    echo "$window_id $pane_id"
  fi
}

find_nvim_target() {
  search_across_windows=$(tmux show-option -gqv @tmux-open-file-nvim-search-all-windows)

  if [[ "$search_across_windows" == "on" ]]; then
    # search across all windows in current session, picking the nearest by window index
    current_session=$(tmux display-message -p '#S')
    current_window_index=$(tmux display-message -p '#I')
    tmux list-panes -a -F '#{session_name} #{window_index} #{window_id} #{pane_id} #{pane_current_command}' \
      | awk -v sess="$current_session" -v cur="$current_window_index" '
          $1 == sess && $5 == "nvim" {
            d = $2 - cur; if (d < 0) d = -d
            if (best == "" || d < best_d) { best_d = d; best = $3 " " $4 }
          }
          END { if (best != "") print best }
        '
  else
    # search only in current window
    pane_info=$(tmux list-panes -F '#{window_id} #{pane_id} #{pane_current_command}' | grep "nvim" | head -1)
    extract_pane_info "$pane_info" 1 2
  fi
}
