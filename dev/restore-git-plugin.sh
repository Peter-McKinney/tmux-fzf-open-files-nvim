#!/usr/bin/env bash

unlink ~/.tmux/plugins/tmux-fzf-open-files-nvim

# replace the local link for the github link
sed -i "s|set -g @plugin 'tmux-plugins/tmux-fzf-open-files-nvim'|set -g @plugin 'Peter-McKinney/tmux-fzf-open-files-nvim'|" ~/.tmux.conf

# install using tpm from the plugins folder
~/.tmux/plugins/tpm/bin/install_plugins
