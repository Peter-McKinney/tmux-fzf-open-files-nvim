#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/../scripts/tmux_find_nvim_pane.sh"

setup() {
  # using this bash function to mock the tmux command for this test
  tmux() {
    "$(pwd)/tests/mock_tmux.sh" "$@"
  }
}

teardown() {
  unset -f tmux
}

@test "should return first tmux nvim pane" {
  result="$(find_nvim_pane)"
  [ "$result" = "%1" ]
}
