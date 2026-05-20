#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/../scripts/tmux_find_nvim_target.sh"

NL=$'\n'
TAB=$'\t'

setup() {
  TMPDIR_TEST=$(mktemp -d)
  export TMPDIR_TEST
}

teardown() {
  rm -rf "$TMPDIR_TEST"
  unset -f tmux fzf
}

@test "find_nvim_target returns empty when no nvim is running in the session" {
  tmux() {
    case "$1 $2" in
      "display-message -p")
        echo "test_session"
        ;;
      "list-panes -a")
        echo -e "test_session\t1\teditor\t@0\t%1\tbash\t/home/u"
        echo -e "test_session\t1\teditor\t@0\t%2\tzsh\t/home/u"
        ;;
      *)
        echo "Unknown tmux command: $*" >&2
        return 1
        ;;
    esac
  }

  result="$(find_nvim_target)"
  [ "$result" = "" ]
}

@test "find_nvim_target returns sole nvim instance without invoking popup" {
  tmux() {
    case "$1 $2" in
      "display-message -p")
        echo "test_session"
        ;;
      "list-panes -a")
        echo -e "test_session\t1\teditor\t@0\t%1\tbash\t/home/u"
        echo -e "test_session\t2\tcode\t@1\t%2\tnvim\t/home/u/repo"
        echo -e "test_session\t3\tlogs\t@2\t%3\tbash\t/home/u"
        ;;
      "display-popup -E"*)
        echo "popup should not have been invoked" >&2
        return 1
        ;;
      *)
        echo "Unknown tmux command: $*" >&2
        return 1
        ;;
    esac
  }

  result="$(find_nvim_target)"
  [ "$result" = "@1 %2" ]
}

@test "find_nvim_target only considers panes in the current session" {
  tmux() {
    case "$1 $2" in
      "display-message -p")
        echo "alpha"
        ;;
      "list-panes -a")
        echo -e "alpha\t1\teditor\t@0\t%1\tnvim\t/home/u/a"
        echo -e "beta\t1\teditor\t@9\t%9\tnvim\t/home/u/b"
        ;;
      *)
        echo "Unknown tmux command: $*" >&2
        return 1
        ;;
    esac
  }

  result="$(find_nvim_target)"
  [ "$result" = "@0 %1" ]
}

@test "find_nvim_target shows fzf popup when multiple nvim instances exist" {
  popup_log="$TMPDIR_TEST/popup_invoked"
  export popup_log

  tmux() {
    case "$1" in
      "display-message")
        echo "test_session"
        ;;
      "list-panes")
        echo -e "test_session\t1\teditor\t@0\t%1\tnvim\t/home/u/a"
        echo -e "test_session\t2\tlogs\t@1\t%2\tbash\t/home/u"
        echo -e "test_session\t3\tnotes\t@2\t%3\tnvim\t/home/u/b"
        ;;
      "display-popup")
        # Expect: display-popup -E "<command>"
        [ "$2" = "-E" ] || {
          echo "popup wrapper: expected -E flag" >&2
          return 1
        }
        touch "$popup_log"
        # Run the inner command with a stub fzf that picks the first row.
        local cmd="$3"
        fzf() { awk 'NF { print; exit }'; }
        export -f fzf
        eval "$cmd"
        ;;
      *)
        echo "Unknown tmux command: $*" >&2
        return 1
        ;;
    esac
  }

  result="$(find_nvim_target)"
  [ -f "$popup_log" ]
  [ "$result" = "@0 %1" ]
}

@test "find_nvim_target returns empty when user cancels the popup" {
  tmux() {
    case "$1" in
      "display-message")
        echo "test_session"
        ;;
      "list-panes")
        echo -e "test_session\t1\teditor\t@0\t%1\tnvim\t/home/u/a"
        echo -e "test_session\t3\tnotes\t@2\t%3\tnvim\t/home/u/b"
        ;;
      "display-popup")
        # User cancels: fzf writes nothing to the outfile.
        local cmd="$3"
        fzf() { return 130; }
        export -f fzf
        eval "$cmd" || true
        ;;
      *)
        echo "Unknown tmux command: $*" >&2
        return 1
        ;;
    esac
  }

  result="$(find_nvim_target)"
  [ "$result" = "" ]
}
