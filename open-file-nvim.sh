#!/bin/bash

cursor_position=$(tmux display-message -p "#{cursor_y} #{cursor_x}")
cursor_y=$(echo $cursor_position | cut -d' ' -f1)

start_line=$((cursor_y - 10))
end_line=$((cursor_y + 10))

captured_content=$(tmux capture-pane -pS $start_line -pE $end_line)

filename=$(captured_content | fzf --query=$(tmux display-message -p "#{pane_current_command}"))

if [ -z "$filename" ]; then
  echo "No filename found under current cursor."
  exit 1
fi

tmux split-window -h -c "#{pane_current_path}" "$EDITOR $filename"
