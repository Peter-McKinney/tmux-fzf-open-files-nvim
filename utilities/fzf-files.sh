#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/../scripts/check_fzf_install.sh"
source "$CURRENT_DIR/../scripts/sanitize.sh"
source "$CURRENT_DIR/../scripts/awk_pane_files.sh"

files=()

if [ "$1" = "--selected-pane-history" ]; then
  while IFS= read -r file; do
    files+=("$file")
  done < <(tmux capture-pane -J -S- -E- -p | parse_files)
elif [ "$1" = "--all-pane-history" ]; then
  # capture each pane history in the current window
  panes=$(tmux list-panes -F '#{pane_id} #{pane_current_command} #{pane_current_path}')

  while IFS= read -r pane; do
    pane_id=$(echo "$pane" | awk '{print $1}')

    while IFS= read -r file; do
      files+=("$file")
    done < <(tmux capture-pane -t "$pane_id" -J -S - -E - -p | parse_files)
  done <<<"$panes"
else
  # capture content visible in the current pane
  while IFS= read -r file; do
    files+=("$file")
  done < <(tmux capture-pane -J -p | parse_files)
fi

if [ ${#files[@]} -eq 0 ]; then
  echo ""
else
  tmpfile=$(mktemp)
  outfile=$(mktemp)
  # go ahead and separate the files by new line. I think fzf loves this
  printf "%s\n" "${files[@]}" >"$tmpfile"

  tmux display-popup -E "fzf -m < \"$tmpfile\" > \"$outfile\""

  selected_files=$(cat "$outfile")
  rm "$tmpfile"
  rm "$outfile"

  echo "$selected_files"
fi
