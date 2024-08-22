#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/check_fzf_install.sh"

check_fzf

if [ -z "$(tmux show-option -gqv @open-file-nvim-key)" ]; then
    tmux bind 'o' run-shell "$CURRENT_DIR/open-file-nvim.sh"
else
    tmux bind "$(tmux show-option -gqv @open-file-nvim-key)" run-shell "$CURRENT_DIR/open-file-nvim.sh"
fi

if [ -z "$(tmux show-option -gqv @open-file-nvim-all-key)" ]; then
    tmux bind 'O' run-shell "$CURRENT_DIR/open-file-nvim.sh --selected-pane-history"
else
    tmux bind "$(tmux show-option -gqv @open-file-nvim-all-key)" run-shell "$CURRENT_DIR/open-file-nvim.sh --selected-pane-history"
fi

if [ -z "$(tmux show-option -gqv @open-file-nvim-all-history-key)" ]; then
    tmux bind 'A' run-shell "$CURRENT_DIR/open-file-nvim.sh --all-pane-history"
else
    tmux bind "$(tmux show-option -gqv @open-file-nvim-all-history-key)" run-shell "$CURRENT_DIR/open-file-nvim.sh --all-pane-history"
fi
