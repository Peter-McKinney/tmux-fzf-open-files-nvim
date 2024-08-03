## TMUX Open File nvim

A plugin that creates a tmux binding to copy the currently selected panes content, filter out anything that isn't a file path, pass the file paths to fzf, then open the file path in your default $EDITOR. Currently, this plugin does not work in copy mode and will still only select the current panes output at the current cursor position (not the position of the cursor in copy mode) OR the entire pane history.

https://github.com/user-attachments/assets/829acfa2-27eb-41b0-95c8-333a7d008810

### Installation 

#### TPM

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

#### Change the default bindings

```bash
set -g @open-file-nvim-key C-m
set -g @open-file-nvim-all-key C-M
```

### Usage

#### Capture the output visible in the current pane: 

The default binding uses `o` so `prefix + o` will run the process to find files in the current pane output. A new horizontal pane will be opened to the right of the current pane. The pane visible text will be sent to `fzf -m` multi select mode so that multiple files may be selected and sent to the $EDITOR.

#### Capture the entire history of the current pane:

The default binding uses `O` so `prefix + O` will run the above process for the entire history of the pane.

### Development

#### Link plugin source locally for testing

In the dev folder, there are scripts to automate linking the plugin locally for development / testing and for resetting the local link to the github link. The scripts edit the ~/.tmux.conf and use the tpm clean and install scripts found in ~/.tmux/plugins/tpm/bin. dev/link-plugin-locally.sh creates a symbolic link to ~/github/tmux-fzf-open-files-nvim. Change this to where your cloned repository exists. 

#### Setting up unit tests and running using bats

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

#### PR Workflow

We use [shellcheck](https://github.com/koalaman/shellcheck) to perform static analysis as a PR check. To install shellcheck locally refer to the installation guide in the shellcheck github. You can also use https://www.shellcheck.net/

To run shellcheck on all files in the project locally:

```bash
 find . -name "*.sh" -print0 | xargs -0 shellcheck -x
```

Warnings will not cause the github action check to fail, only errors should be fixed. 
