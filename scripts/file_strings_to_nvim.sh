#!/usr/bin/env bash

FILES_LN_REGEX="([^:]+):([0-9]+):([0-9]+)"

to_tabedit_strings() {
  files="$1"
  # obligatory comment so I remember how this works
  # append tabedit to the front of each line
  # for lines matching the regex for line numberss, convert to neovim
  # linenumber string. Remove newlines and append |
  echo "$files" | sed -E "/$FILES_LN_REGEX/! s/^/tabedit /" | sed -E "s/$FILES_LN_REGEX/tabedit \+call\\\ cursor\(\2,\3\) \1/g; s/$/ |/" | tr '\n' ' | '
}
