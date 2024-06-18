#!/bin/bash

# get active cursor position from active tmux pane
cursor_position=$(tmux display-message -p "#{cursor_y} #{cursor_x}")
cursor_y=$(echo $cursor_position | cut -d' ' -f1)

# capture ten lines up, ten lines down from current cursor position
start_line=$((cursor_y - 10))
end_line=$((cursor_y + 10))

# send capture pane command
captured_content=$(tmux capture-pane -pS $start_line -pE $end_line)

filename=$(captured_content | fzf --query=$(tmux display-message -p "#{pane_current_command}"))

echo "$filename"

if [ -z "$filename" ]; then
  echo "No filename found under current cursor."
  exit 1
fi

# Open the file in a new tmux pane
tmux split-window -h -c "#{pane_current_path}" "$EDITOR $filename"
