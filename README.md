# TMUX Open File nvim

A tmux plugin to parse terminal output for filenames and open them in neovim. It works by creating a tmux binding to copy the currently selected panes content, match output that is a file path ending in an extension or with location information 83:57, pass the file paths to fzf, and open the fzf selected files in your default $EDITOR (only tested with neovim currently). 

https://github.com/user-attachments/assets/f90bd8f9-dd56-420b-b708-c2cc51cea70f

---
[![Tests](https://github.com/Peter-McKinney/tmux-fzf-open-files-nvim/actions/workflows/tests.yml/badge.svg)](https://github.com/Peter-McKinney/tmux-fzf-open-files-nvim/actions/workflows/tests.yml)
[![Run shellcheck](https://github.com/Peter-McKinney/tmux-fzf-open-files-nvim/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/Peter-McKinney/tmux-fzf-open-files-nvim/actions/workflows/shellcheck.yml)

## Installation 

### TPM

Using TPM, add the following lines to your ~/.tmux.conf:

```bash
set -g @plugin 'Peter-McKinney/tmux-open-file-nvim'
```

Use `prefix + I` to install the plugin which should also source your ~/.tmux.conf but just in case: `prefix + :source ~/.tmux.conf`

Make sure to have your editor environment variable set to neovim:

```bash
export EDITOR='nvim'
```

Please make sure that fzf is installed by following the directions over at: https://github.com/junegunn/fzf

## Usage

### Keybindings: 

| Variable Name           | Description                                                           | Default Binding |
|-------------------------|-----------------------------------------------------------------------|-----------------|
| @open-file-nvim-key     | Parses the current visible pane output for filenames                  | C-o             |
| @open-file-nvim-all-key | Parses the entire available history in the current pane for filenames | C-o             |

### Capture the output visible in the current pane: 

The default binding uses `o` so `prefix + o` will run the process to find files in the current pane output. A new horizontal pane will be opened to the right of the current pane. The pane visible text will be sent to `fzf -m` multi select mode so that multiple files may be selected and sent to the $EDITOR.

### Capture the entire history of the current pane:

The default binding uses `O` so `prefix + O` will run the above process for the entire history of the current pane.

### Change the default bindings

```bash
set -g @open-file-nvim-key {newbinding}
set -g @open-file-nvim-all-key {newbinding}
```

## Development

### Link plugin source locally for testing

In the dev folder, there are scripts to automate linking the plugin locally for development / testing and for resetting the local link to the github link. The scripts edit the `~/.tmux.conf` and use the tpm clean and install scripts found in `~/.tmux/plugins/tpm/bin` to remove and install plugins. `dev/link-plugin-locally.sh` creates a symbolic link to `~/github/tmux-fzf-open-files-nvim`. Change this to where your cloned repository resides.  You can then run `dev/link-plugin-locally.sh` to restore the github plugin source.

### Setting up unit tests and running using bats

We use the bats unit test framework to write and execute bash unit tests https://github.com/bats-core/bats-core. Refer to https://bats-core.readthedocs.io/en/stable/installation.html for the full installation instructions. Here are common ones: 

MacOS using homebrew: 
```bash
brew install bats-core
```

Ubuntu:
```bash
sudo apt install bats
```

To run the unit tests:
```bash
bats tests
```

### Github Actions

We use [shellcheck](https://github.com/koalaman/shellcheck) to perform static analysis as a PR check. To install shellcheck locally refer to the installation guide in the shellcheck github. You can also use https://www.shellcheck.net/

To run shellcheck on all files in the project locally:

```bash
 find . -name "*.sh" -print0 | xargs -0 shellcheck -x
```

Warnings will not cause the github action check to fail, only errors.

We also run the bats tests as a part of the PR check workflow.
