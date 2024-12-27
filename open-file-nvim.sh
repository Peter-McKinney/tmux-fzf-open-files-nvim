#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/check_fzf_install.sh"

check_fzf

editor_files=$(source "$CURRENT_DIR/utilities/fzf-files.sh" "$1")

if [[ -z "$editor_files" ]]; then
  echo "No files found or selected through fzf"
else
  source "$CURRENT_DIR/scripts/tmux_find_nvim_pane.sh"
  nvim_pane_id=$(find_nvim_pane)

  if [[ -n "$nvim_pane_id" ]]; then
    nvim_command="$(echo "$editor_files" | sed 's/[^ ]\+/tabedit & |/g' | tr '\n' ' | ')"
    tmux send-keys -t "$nvim_pane_id" Escape ":$nvim_command" Enter
    tmux select-pane -t "$nvim_pane_id"
  else
    # sed script will match :number:number at the end of a string for
    # supporting opening files at a target row, col location
    tmux split-window -h -c "#{pane_current_path}" "echo \"$editor_files\" | sed -E 's/([^:]+):([0-9]+):([0-9]+)/-c e \1 \| normal \2G\3\|/g' |
    xargs -I {} $EDITOR {}"
  fi
fi
