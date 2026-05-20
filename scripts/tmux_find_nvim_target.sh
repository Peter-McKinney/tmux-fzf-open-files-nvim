#!/usr/bin/env bash

create_nvim_pane() {
  local new_pane window_id pane_id
  new_pane=$(tmux split-window -h -P -F '#{window_id} #{pane_id}' -c "#{pane_current_path}")
  read -r window_id pane_id <<<"$new_pane"
  tmux send-keys -t "$pane_id" "nvim" Enter

  echo "$window_id $pane_id"
}

# Emits one line per nvim pane in the current session, tab-separated:
#   window_id<TAB>pane_id<TAB>window_index<TAB>window_name<TAB>pane_current_path
list_nvim_instances() {
  local current_session
  current_session=$(tmux display-message -p '#S')
  tmux list-panes -a -F $'#{session_name}\t#{window_index}\t#{window_name}\t#{window_id}\t#{pane_id}\t#{pane_current_command}\t#{pane_current_path}' |
    awk -F'\t' -v sess="$current_session" '
      $1 == sess && $6 == "nvim" {
        printf "%s\t%s\t%s\t%s\t%s\n", $4, $5, $2, $3, $7
      }
    '
}

# Given the tab-separated instance list on stdin, show a tmux popup running fzf
# so the user can choose which nvim to target. Echoes "<window_id> <pane_id>"
# for the selected instance (or empty if the user cancelled).
pick_nvim_instance() {
  local instances="$1"
  local tmpfile outfile selected
  tmpfile=$(mktemp)
  outfile=$(mktemp)
  # Build rows: window_id<TAB>pane_id<TAB>display_text  (fzf only renders the display column)
  echo "$instances" | awk -F'\t' '{ printf "%s\t%s\t%s:%s \xe2\x80\x94 %s\n", $1, $2, $3, $4, $5 }' >"$tmpfile"
  tmux display-popup -E "fzf --delimiter=\$'\\t' --with-nth=3.. < \"$tmpfile\" > \"$outfile\""
  selected=$(cat "$outfile")
  rm -f "$tmpfile" "$outfile"
  [[ -z "$selected" ]] && return
  awk -F'\t' '{ print $1, $2 }' <<<"$selected"
}

# Finds the nvim pane to target. Echoes "<window_id> <pane_id>" or nothing.
# Search is session-wide. If multiple nvim panes are running, prompts the user
# via an fzf popup to pick one.
find_nvim_target() {
  local instances count
  instances=$(list_nvim_instances)
  [[ -z "$instances" ]] && return

  count=$(printf '%s\n' "$instances" | wc -l | tr -d ' ')
  if [[ "$count" -eq 1 ]]; then
    awk -F'\t' '{ print $1, $2 }' <<<"$instances"
  else
    pick_nvim_instance "$instances"
  fi
}

get_nvim_pane() {
  local nvim_info
  nvim_info=$(find_nvim_target)

  if [[ -z "$nvim_info" ]]; then
    create_nvim_pane
  else
    echo "$nvim_info"
  fi
}
