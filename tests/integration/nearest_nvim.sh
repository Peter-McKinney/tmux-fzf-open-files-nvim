#!/usr/bin/env bash
# End-to-end check that find_nvim_target picks the nvim instance whose
# window index is closest to the current window when search-all-windows
# is enabled.
#
# How it works:
#   * Starts a detached tmux server on a private socket with five windows.
#   * Launches a real `nvim` in a configurable subset of those windows
#     and waits for tmux to report `pane_current_command == nvim`.
#   * Selects a "current" window, then sources the plugin's helper and
#     invokes find_nvim_target with a stubbed show-option (so the helper
#     thinks @tmux-open-file-nvim-search-all-windows is "on") and a tmux
#     wrapper that forwards every other call to the private socket.
#   * Translates the returned `@<wid> %<pid>` back to a window index and
#     asserts it matches the expected nearest window.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOCKET="tfof-nearest-$$"
SESSION="t"
PASS=0
FAIL=0

cleanup() {
  tmux -L "$SOCKET" kill-server 2>/dev/null || true
}
trap cleanup EXIT

wait_for_cmd() {
  local target_pane="$1" want="$2" got=""
  for _ in $(seq 1 80); do
    got=$(tmux -L "$SOCKET" display-message -p -t "$target_pane" '#{pane_current_command}')
    [[ "$got" == "$want" ]] && return 0
    sleep 0.1
  done
  echo "  timed out waiting for $target_pane to be running '$want' (last: '$got')" >&2
  return 1
}

# run_case <name> <current-window-idx> <expected-window-idx> <nvim-window-idx>...
run_case() {
  local name="$1" current_idx="$2" expected_idx="$3"
  shift 3
  local nvim_windows=("$@")

  tmux -L "$SOCKET" kill-session -t "$SESSION" 2>/dev/null || true
  tmux -L "$SOCKET" new-session -d -s "$SESSION" -x 200 -y 50

  for i in 1 2 3 4; do
    tmux -L "$SOCKET" new-window -t "$SESSION:$i"
  done

  local w pane_id
  for w in "${nvim_windows[@]}"; do
    tmux -L "$SOCKET" send-keys -t "$SESSION:$w" "nvim --clean -n" Enter
    pane_id=$(tmux -L "$SOCKET" display-message -p -t "$SESSION:$w" '#{pane_id}')
    if ! wait_for_cmd "$pane_id" "nvim"; then
      echo "[FAIL] $name (nvim never started in window $w)"
      FAIL=$((FAIL + 1))
      return
    fi
  done

  tmux -L "$SOCKET" select-window -t "$SESSION:$current_idx"

  local result
  result=$(
    export PLUGIN_DIR SOCKET
    bash -c '
      source "$PLUGIN_DIR/scripts/tmux_find_nvim_target.sh"
      tmux() {
        if [[ "$1 $2 $3" == "show-option -gqv @tmux-open-file-nvim-search-all-windows" ]]; then
          echo "on"
          return
        fi
        command tmux -L "$SOCKET" "$@"
      }
      find_nvim_target
    '
  )

  local picked_wid picked_pid picked_idx
  read -r picked_wid picked_pid <<<"$result"
  if [[ -z "$picked_wid" ]]; then
    picked_idx="(none)"
  else
    picked_idx=$(tmux -L "$SOCKET" display-message -p -t "$picked_wid" '#{window_index}' 2>/dev/null || echo "?")
  fi

  if [[ "$picked_idx" == "$expected_idx" ]]; then
    echo "[PASS] $name  (current=$current_idx, nvim in {${nvim_windows[*]}}, picked window $picked_idx)"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] $name  (current=$current_idx, nvim in {${nvim_windows[*]}})"
    echo "       expected window: $expected_idx"
    echo "       got window:      $picked_idx   (raw: '$result')"
    FAIL=$((FAIL + 1))
  fi
}

# Args: name, current-window, expected-window, nvim-windows...
run_case "nearest is to the right" 3 4 0 4
run_case "nearest is to the left" 1 0 0 4
run_case "current window wins (distance 0)" 1 1 0 1 4
run_case "single nvim far away is still picked" 0 4 4
run_case "three candidates, middle is closest" 2 3 0 3 4

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
