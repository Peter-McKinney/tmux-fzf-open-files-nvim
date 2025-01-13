#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/awk_pane_files.sh"

sanitize_pane_output() {
  remove_invalid_characters |
    remove_http_ftp |
    handle_home_folder_expansion
}

# remove http and ftp urls.
remove_http_ftp() {
  sed -E 's/http[^ ]*//g; s/ftp[^ ]*//g'
}

#handle ~ home expansion
handle_home_folder_expansion() {
  sed "s/~/\$HOME/g"
}
