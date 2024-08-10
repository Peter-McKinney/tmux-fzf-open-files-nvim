#!/usr/bin/env bash

# awk for anything that resembles a file path with a file extension on the end.
# only return unique paths
# temporarily override locale settings for awk command
parse_files() {
  files=$(echo "$1" | LC_ALL=C awk '{
    while (match($0, /[^[:space:]]*\/[[:alnum:]._-]+(\/[[:alnum:]._-]+)*\.[[:alnum:]]+(:[0-9]+:[0-9]+)?/)) {
        path = substr($0, RSTART, RLENGTH)
        if (!seen[path]++) {
            print path
        }
        $0 = substr($0, RSTART + RLENGTH)
    }
    }')

  echo "$files"
}

# remove invliad file path characters by using gsub with an allow list regular expression
# temporarily override locale settings for awk command
remove_invalid_characters() {
  pristine=$(echo "$1" | LC_ALL=C awk '{ gsub(/[^[:alnum:][:space:].:_~\/-]/, "", $0); print }')
  echo "$pristine"
}
