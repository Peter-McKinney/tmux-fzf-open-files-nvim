#!/usr/bin/env bash

# awk for anything that resembles a file path with a file extension on the end.
# only return unique paths using seen
# modified this to allow for incremental parsing using streaming.
# intended use is through a pipe like: tmux capture-pane | parse-files
parse_files() {
  LC_ALL=C awk '
  BEGIN { RS = "\n"; FS = ""; }
  {
    while (match($0, /[^[:space:]"]*\/[[:alnum:]._-]+(\/[[:alnum:]._-]+)*\.[[:alnum:]]+(:[0-9]+:[0-9]+)?/)) {
      path = substr($0, RSTART, RLENGTH)
      if (!seen[path]++) {
        print path
      }
      $0 = substr($0, RSTART + RLENGTH)  # Skip the matched part
    }
  }'
}

# remove invalid file path characters by using gsub with an allow list regular expression
# temporarily override locale settings for awk command
remove_invalid_characters() {
  LC_ALL=C awk '{ gsub(/[^[:alnum:][:space:].:_~\/-]/, "", $0); print }'
}
