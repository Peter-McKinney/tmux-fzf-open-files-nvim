#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/awk_pane_files.sh"

sanitize_pane_output() {
  sanitized_content=$(remove_invalid_characters "$1")
  sanitized_content=$(remove_http_ftp "$sanitized_content")
  sanitized_content=$(handle_home_folder_expansion "$sanitized_content")
  echo "$sanitized_content"
}

# remove http and ftp urls.
remove_http_ftp() {
  removed=$(echo "$1" | sed 's/http[^ ]*//g')
  removed=$(echo "$removed" | sed 's/ftp[^ ]*//g')
  echo "$removed"
}

#handle ~ home expansion
handle_home_folder_expansion() {
  files=$(echo "$1" | sed "s/~/\$HOME/g")
  echo "$files"
}
