#!/usr/bin/env bash

check_fzf() {
  if ! command -v fzf &>/dev/null; then
    echo "fzf could not be found"
    echo "Please install fzf https://github.com/junegunn/fzf"
    exit 1
  fi
}
