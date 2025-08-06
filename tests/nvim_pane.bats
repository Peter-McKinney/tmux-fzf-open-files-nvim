#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/../scripts/tmux_find_nvim_target.sh"

setup() {
  # using this bash function to mock the tmux command for this test
  tmux() {
    "$(pwd)/tests/mock_tmux.sh" "$@"
  }
}

teardown() {
  unset -f tmux
}

@test "should return first tmux nvim pane when search-all-windows is off (default)" {
  result="$(find_nvim_target)"
  [ "$result" = "@0 %1" ]
}

@test "should find nvim in different window when search-all-windows is on" {
  export TMUX_OPTION_tmux_open_file_nvim_search_all_windows="on"

  # Mock scenario where current window has no nvim, but another window does
  tmux() {
    case "$*" in
      "display-message -p #S")
        echo "test_session"
        ;;
      "list-panes -a -F #{session_name} #{window_id} #{pane_id} #{pane_current_command}")
        echo "test_session @0 %1 bash"
        echo "test_session @0 %2 bash"
        echo "test_session @1 %3 bash"
        echo "test_session @1 %4 nvim"
        ;;
      "show-option -gqv @tmux-open-file-nvim-search-all-windows")
        echo "on"
        ;;
      *)
        echo "Unknown tmux command: $*" >&2
        exit 1
        ;;
    esac
  }

  result="$(find_nvim_target)"
  [ "$result" = "@1 %4" ]
}

@test "should not find nvim in different window when search-all-windows is off" {
  export TMUX_OPTION_tmux_open_file_nvim_search_all_windows="off"

  # Mock scenario where current window has no nvim, but another window does
  tmux() {
    case "$*" in
      "show-option -gqv @tmux-open-file-nvim-search-all-windows")
        echo "off"
        ;;
      "list-panes -F #{window_id} #{pane_id} #{pane_current_command}")
        echo "@0 %1 bash"
        echo "@0 %2 bash"
        ;;
      *)
        echo "Unknown tmux command: $*" >&2
        exit 1
        ;;
    esac
  }

  result="$(find_nvim_target)"
  [ "$result" = "" ]
}
