#!/usr/bin/env bash

# replace the github link for the local tmux-plugins link, commented out
sed -i "s|set -g @plugin 'Peter-McKinney/tmux-fzf-open-files-nvim'|#set -g @plugin 'tmux-plugins/tmux-fzf-open-files-nvim'|" ~/.tmux.conf

# uninstall using tpm from the plugin folder
~/.tmux/plugins/tpm/bin/clean_plugins

# link this repository to the tmux plugins
ln -s ~/github/tmux-fzf-open-files-nvim ~/.tmux/plugins/tmux-fzf-open-files-nvim

# uncomment local link
sed -i "s|#set -g @plugin 'tmux-plugins/tmux-fzf-open-files-nvim'|set -g @plugin 'tmux-plugins/tmux-fzf-open-files-nvim'|" ~/.tmux.conf
