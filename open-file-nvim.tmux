#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/check_fzf_install.sh"

check_fzf

if [ -z "$(tmux show-option -gqv @open-file-key)" ]; then
    tmux bind -n 'o' open_files
else
    tmux bind -n "$(tmux show-option -gqv @open-file-nvim-key)" open_files
fi

open_files() {
    run-shell "~/.tmux/plugins/tmux-open-file-nvim/open-file-nvim.sh";
}
