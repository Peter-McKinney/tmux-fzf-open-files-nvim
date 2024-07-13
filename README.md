## TMUX Open File nvim

A plugin that creates a tmux binding to copy the currently selected panes content, filter out anything that isn't a file path, pass the file paths to fzf, then open the file path in your default $EDITOR. Currently, this plugin does not work in copy mode and will still only select the current panes output at the current cursor position (not the position of the cursor in copy mode).

### Installing

#### TPM

Using TPM, add the following lines to your ~/.tmux.conf:

```bash
set -g @plugin 'Peter-McKinney/tmux-open-file-nvim'
```

Use `prefix + I` to install the plugin and source your ~/.tmux.conf by `prefix + :source ~/.tmux.conf`

### Usage

The default binding uses `o` so `prefix + o` will run the process to find files in the current pane output.
