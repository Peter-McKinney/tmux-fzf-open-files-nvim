#!/usr/bin/env bash

if ! command -v fzf &> /dev/null
then
    echo "fzf could not be found"
    echo "Please install fzf https://github.com/junegunn/fzf"
    exit 1
fi

if [ -z "$(tmux show-option -gqv @open-file-key)" ]; then
	tmux bind 'o' run-shell "~/.tmux/plugins/tmux-open-file-nvim/open-file-nvim.sh"
else 
	tmux bind-key -n "$(tmux show-option -gqv @open-file-key)" run-shell "~/.tmux/plugins/tmux-open-file-nvim/open-file-nvim.sh";
fi
