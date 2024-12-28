#!/usr/bin/env bash

FILES_LINENUMBER_REGEX="([^:]+):([0-9]+):([0-9]+)"

to_tabedit_strings() {
  files="$1"
  echo "$files" | sed -E "s/$FILES_LINENUMBER_REGEX/tabedit \+call\\\ cursor\(\2,\3\) \1 \|/g"
}

to_buffer_strings() {
  files="$1"
  echo "$files" | sed -E "s|$FILES_LINENUMBER_REGEX|e +call\\\ cursor\(\2,\3\) \1|g"
}
