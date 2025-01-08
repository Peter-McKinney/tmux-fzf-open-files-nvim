#!/bin/bash

case "$*" in
"list-panes -F #{pane_id} #{pane_current_command}")
  echo "%1 nvim"
  echo "%2 bash"
  echo "%3 nvim"
  ;;
"send-keys -t %1 :echo 'Hello from tmux!' Enter")
  echo "Command sent to Neovim pane"
  ;;
"select-pane -t %1")
  echo "Focused pane %1"
  ;;
*)
  echo "Unknown tmux command: $*" >&2
  exit 1
  ;;
esac
