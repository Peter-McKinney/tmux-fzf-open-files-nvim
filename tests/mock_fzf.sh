#!/bin/bash

# Mock check_fzf function - always succeeds in tests
check_fzf() {
  return 0
}

# Mock fzf command - provides test behavior
fzf() {
  # If there's input from stdin, just return the first line
  # This simulates selecting the first option in fzf
  head -n 1
}
