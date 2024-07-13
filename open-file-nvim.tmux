#!/usr/bin/env bash

if ! command -v fzf &> /dev/null
then
    echo "fzf could not be found"
    echo "Please install fzf https://github.com/junegunn/fzf"
    exit 1
fi

bind-key y run-shell "~/.tmux/plugins/tmux-open-file-nvim/open-file-nvim.sh"
