#!/usr/bin/env bash
# End-to-end check that find_nvim_target finds nvim instances across all
# windows in the current session and, when more than one is running, hands
# the choice off to a tmux popup running fzf.
#
# How it works:
#   * Starts a detached tmux server on a private socket with several windows.
#   * Launches a real `nvim` in a configurable subset of those windows and
#     waits for tmux to report `pane_current_command == nvim`.
#   * Sources the plugin's helper inside a wrapper that:
#       - puts a stub `fzf` on PATH that always picks the first row, and
#       - overrides the `tmux` shell function so `display-popup -E "<cmd>"`
#         runs <cmd> directly with the stub fzf available. All other tmux
#         calls still hit the real server.
#   * Verifies that find_nvim_target returns the expected nvim pane and
#     that the popup was (or was not) invoked, depending on the case.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKDIR="$(mktemp -d -t tfof-pick-XXXXXX)"
SOCKET="tfof-pick-$$"
SESSION="t"
PASS=0
FAIL=0

cleanup() {
  tmux -L "$SOCKET" kill-server 2>/dev/null || true
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

cat >"$WORKDIR/fzf" <<'STUB'
#!/usr/bin/env bash
# Stub fzf: ignores all flags, prints the first non-empty stdin line.
awk 'NF { print; exit }'
STUB
chmod +x "$WORKDIR/fzf"

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

# run_case <name> <expect-popup:yes|no> <expected-window-idx> <nvim-window-idx>...
run_case() {
  local name="$1" expect_popup="$2" expected_idx="$3"
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

  rm -f "$WORKDIR/popup_invoked"

  local result
  result=$(
    export PLUGIN_DIR SOCKET WORKDIR
    bash -c '
      source "$PLUGIN_DIR/scripts/tmux_find_nvim_target.sh"
      tmux() {
        if [[ "$1" == "display-popup" ]]; then
          touch "$WORKDIR/popup_invoked"
          [[ "$2" == "-E" ]] || { echo "popup wrapper: expected -E after display-popup" >&2; return 1; }
          PATH="$WORKDIR:$PATH" bash -c "$3"
          return
        fi
        command tmux -L "$SOCKET" "$@"
      }
      find_nvim_target
    '
  )

  local picked_wid picked_idx
  read -r picked_wid _ <<<"$result"
  if [[ -z "$picked_wid" ]]; then
    picked_idx="(none)"
  else
    picked_idx=$(tmux -L "$SOCKET" display-message -p -t "$picked_wid" '#{window_index}' 2>/dev/null || echo "?")
  fi

  local popup_seen="no"
  [[ -f "$WORKDIR/popup_invoked" ]] && popup_seen="yes"

  if [[ "$picked_idx" == "$expected_idx" && "$popup_seen" == "$expect_popup" ]]; then
    echo "[PASS] $name  (nvim in {${nvim_windows[*]}}, picked window $picked_idx, popup=$popup_seen)"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] $name  (nvim in {${nvim_windows[*]}})"
    echo "       expected window: $expected_idx   popup=$expect_popup"
    echo "       got window:      $picked_idx     popup=$popup_seen  (raw: '$result')"
    FAIL=$((FAIL + 1))
  fi
}

# Args: name, expect-popup, expected-window, nvim-windows...
run_case "single nvim is picked without popup" no 2 2
run_case "multi nvim: popup invoked, first row chosen" yes 0 0 3
run_case "multi nvim across far windows: popup invoked" yes 1 1 4

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
