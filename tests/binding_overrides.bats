#!/usr/bin/env bats

# Load mock tmux and fzf functions
source "$BATS_TEST_DIRNAME/mock_tmux.sh"
source "$BATS_TEST_DIRNAME/mock_fzf.sh"

setup() {
  # Clear any existing options and binds
  unset TMUX_OPTIONS
  unset TMUX_BINDS
  unset TMUX_OPTION_open_file_nvim_key
  unset TMUX_OPTION_open_file_nvim_all_key
  unset TMUX_OPTION_open_file_nvim_all_history_key
  declare -a TMUX_BINDS
  export TMUX_BINDS
}

@test "default bindings use F, H, G when no custom options set" {
  source "$BATS_TEST_DIRNAME/../open-file-nvim.tmux"
  
  # Check that F, H, G were bound
  [[ " ${TMUX_BINDS[*]} " =~ " F " ]]
  [[ " ${TMUX_BINDS[*]} " =~ " H " ]]
  [[ " ${TMUX_BINDS[*]} " =~ " G " ]]
}

@test "custom binding for @open-file-nvim-key overrides default F" {
  # Set custom option via environment variable
  export TMUX_OPTION_open_file_nvim_key="z"
  
  source "$BATS_TEST_DIRNAME/../open-file-nvim.tmux"
  
  # Check that z was bound instead of F
  [[ " ${TMUX_BINDS[*]} " =~ " z " ]]
  [[ ! " ${TMUX_BINDS[*]} " =~ " F " ]]
}

@test "custom binding for @open-file-nvim-all-key overrides default H" {
  # Set custom option via environment variable
  export TMUX_OPTION_open_file_nvim_all_key="x"
  
  source "$BATS_TEST_DIRNAME/../open-file-nvim.tmux"
  
  # Check that x was bound instead of H
  [[ " ${TMUX_BINDS[*]} " =~ " x " ]]
  [[ ! " ${TMUX_BINDS[*]} " =~ " H " ]]
}

@test "custom binding for @open-file-nvim-all-history-key overrides default G" {
  # Set custom option via environment variable
  export TMUX_OPTION_open_file_nvim_all_history_key="y"
  
  source "$BATS_TEST_DIRNAME/../open-file-nvim.tmux"
  
  # Check that y was bound instead of G
  [[ " ${TMUX_BINDS[*]} " =~ " y " ]]
  [[ ! " ${TMUX_BINDS[*]} " =~ " G " ]]
}

@test "all custom bindings can be set together" {
  # Set all custom options via environment variables
  export TMUX_OPTION_open_file_nvim_key="1"
  export TMUX_OPTION_open_file_nvim_all_key="2"
  export TMUX_OPTION_open_file_nvim_all_history_key="3"
  
  source "$BATS_TEST_DIRNAME/../open-file-nvim.tmux"
  
  # Check that custom keys were bound
  [[ " ${TMUX_BINDS[*]} " =~ " 1 " ]]
  [[ " ${TMUX_BINDS[*]} " =~ " 2 " ]]
  [[ " ${TMUX_BINDS[*]} " =~ " 3 " ]]
  
  # Check that default keys were not bound
  [[ ! " ${TMUX_BINDS[*]} " =~ " F " ]]
  [[ ! " ${TMUX_BINDS[*]} " =~ " H " ]]
  [[ ! " ${TMUX_BINDS[*]} " =~ " G " ]]
}