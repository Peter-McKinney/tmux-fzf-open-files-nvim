#!/usr/bin/env bash

escape_input() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

if ! command -v fzf &> /dev/null
then
    echo "fzf could not be found"
    echo "Please install fzf https://github.com/junegunn/fzf"
    exit 1
fi

buffer_name="tmux_capture_buffer"

tmux capture-pane -J -b "$buffer_name"
captured_content=$(tmux show-buffer -b "$buffer_name")
escaped_content=$(escape_input "$captured_content")

files=$(echo "$escaped_content" | awk '{
    while (match($0, /[^[:space:]("]*\/[[:alnum:]._-]+(\/[[:alnum:]._-]+)*\.[[:alnum:]]+/)) {
        path = substr($0, RSTART, RLENGTH)
        if (!seen[path]++) {
            print path
        }
        $0 = substr($0, RSTART + RLENGTH)
    }
}')

if [ -z "$files" ]; then
  echo "No files found."
else
  tmux split-window -h -c "#{pane_current_path}" "echo \"$files\" | fzf -m | xargs -I {} $EDITOR {}"
fi
