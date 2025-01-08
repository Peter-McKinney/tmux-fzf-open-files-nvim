#!/usr/bin/env bash

find_nvim_pane() {
  pane_ids=$(tmux list-panes -F '#{pane_id} #{pane_current_command}')
  nvim_pane=$(echo "$pane_ids" | grep "nvim")
  nvim_pane_id=${nvim_pane%% *}
  echo "$nvim_pane_id"
}
