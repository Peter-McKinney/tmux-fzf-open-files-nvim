# Define the plugin name and description
set -g @open-file-nvim-plugin 'open-file-nvim'

# Define the plugin command
bind-key f run-shell "~/.tmux/plugins/tmux-open-file-nvim/open-file-nvim.sh"
