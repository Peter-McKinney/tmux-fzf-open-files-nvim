#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/check_fzf_install.sh"

check_fzf

remove_invalid_path_characters() {
    echo "$1" | awk '{ gsub(/[^[:alnum:][:space:]._~\/-]/, ""); print }'
}

buffer_name="tmux_capture_buffer"

tmux capture-pane -J -b "$buffer_name"
captured_content=$(tmux show-buffer -b "$buffer_name")

# remove any characters that are not valid in a file path
# remove http or ftp urls.
sanitized_content=$(remove_invalid_path_characters "$captured_content")
sanitized_content=$(echo "$sanitized_content" | sed 's/http[^ ]*//g')
sanitized_content=$(echo "$sanitized_content" | sed 's/ftp[^ ]*//g');

# awk for anything that resembles a file path with a file extension on the end.
# only return unique paths
files=$(echo "$sanitized_content" | awk '{
    while (match($0, /[^[:space:]]*\/[[:alnum:]._-]+(\/[[:alnum:]._-]+)*\.[[:alnum:]]+/)) {
        path = substr($0, RSTART, RLENGTH)
        if (!seen[path]++) {
            print path
        }
        $0 = substr($0, RSTART + RLENGTH)
    }
}')

#handle ~ home expansion
files=$(echo "$files" | sed 's/~/\$HOME/g')

if [ -z "$files" ]; then
    echo "No files found."
else
    tmux split-window -h -c "#{pane_current_path}" "echo \"$files\" | fzf -m | xargs -I {} $EDITOR {}"
fi

tmux delete-buffer -b "$buffer_name"
