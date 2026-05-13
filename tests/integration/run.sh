#!/usr/bin/env bash
# End-to-end check that fzf-files.sh, given file paths visible in a real tmux
# pane, extracts them, opens the popup, lets fzf select one, and prints it.
#
# How it works:
#   * Starts a detached tmux server on a private socket.
#   * Echoes file-path-shaped strings into the pane so capture-pane sees them.
#   * Runs utilities/fzf-files.sh inside that pane, but inside a wrapper that:
#       - puts a stub `fzf` (picks the first line) on PATH, and
#       - overrides the `tmux` shell function so that `display-popup -E "<cmd>"`
#         runs <cmd> directly. All other tmux calls still hit the real server.
#   * Asserts that the popup wrapper was invoked AND the script printed the
#     first matching file path.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKDIR="$(mktemp -d -t tfof-int-XXXXXX)"
SOCKET="tfof-int-$$"
SESSION="test"
PASS=0
FAIL=0

cleanup() {
  tmux -L "$SOCKET" kill-server 2>/dev/null || true
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

# --- Stub fzf: ignores flags, prints the first non-empty line of stdin. ---
cat >"$WORKDIR/fzf" <<'STUB'
#!/usr/bin/env bash
awk 'NF { print; exit }'
STUB
chmod +x "$WORKDIR/fzf"

# --- Runner: bypasses display-popup rendering, runs the inner command. ---
cat >"$WORKDIR/runner.sh" <<RUNNER
#!/usr/bin/env bash
set -euo pipefail

tmux() {
  if [[ "\$1" == "display-popup" ]]; then
    touch "$WORKDIR/popup_invoked"
    local cmd="" found=0
    for arg in "\$@"; do
      if [[ \$found -eq 1 ]]; then
        cmd="\$arg"
        break
      fi
      [[ "\$arg" == "-E" ]] && found=1
    done
    eval "\$cmd"
    return \$?
  fi
  command tmux "\$@"
}
export -f tmux

PATH="$WORKDIR:\$PATH" bash "$PLUGIN_DIR/utilities/fzf-files.sh" "\${1:-}"
RUNNER
chmod +x "$WORKDIR/runner.sh"

run_case() {
  local name="$1"
  local expected="$2"
  shift 2
  local arg="${1:-}"

  rm -f "$WORKDIR/out" "$WORKDIR/done" "$WORKDIR/popup_invoked"

  tmux -L "$SOCKET" send-keys -t "$SESSION" "clear" Enter
  sleep 0.2
  tmux -L "$SOCKET" send-keys -t "$SESSION" "echo scripts/awk_pane_files.sh" Enter
  tmux -L "$SOCKET" send-keys -t "$SESSION" "echo src/utils/parser.go:42" Enter
  tmux -L "$SOCKET" send-keys -t "$SESSION" "echo tests/awk_pane_files.bats" Enter
  sleep 0.3

  tmux -L "$SOCKET" send-keys -t "$SESSION" \
    "bash '$WORKDIR/runner.sh' $arg >'$WORKDIR/out' 2>&1; touch '$WORKDIR/done'" Enter

  for _ in $(seq 1 40); do
    [ -f "$WORKDIR/done" ] && break
    sleep 0.25
  done

  if [ ! -f "$WORKDIR/done" ]; then
    echo "[FAIL] $name: runner did not complete within 10s"
    FAIL=$((FAIL + 1))
    return
  fi

  local result
  result="$(cat "$WORKDIR/out")"

  if [ ! -f "$WORKDIR/popup_invoked" ]; then
    echo "[FAIL] $name: display-popup was never invoked"
    echo "       output: $result"
    FAIL=$((FAIL + 1))
    return
  fi

  if [[ "$result" != "$expected" ]]; then
    echo "[FAIL] $name"
    echo "       expected: $expected"
    echo "       got:      $result"
    FAIL=$((FAIL + 1))
    return
  fi

  echo "[PASS] $name"
  PASS=$((PASS + 1))
}

tmux -L "$SOCKET" new-session -d -s "$SESSION" -x 200 -y 50

run_case "visible pane (default)" "scripts/awk_pane_files.sh"
run_case "selected pane history" "scripts/awk_pane_files.sh" "--selected-pane-history"
run_case "all pane history" "scripts/awk_pane_files.sh" "--all-pane-history"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
