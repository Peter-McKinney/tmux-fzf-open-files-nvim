source "$CURRENT_DIR/awk_pane_files.sh"

# remove http or ftp urls.
sanitize_pane_output() {
    sanitized_content=$(remove_invalid_characters "$1")
    sanitized_content=$(echo "$sanitized_content" | sed 's/http[^ ]*//g')
    sanitized_content=$(echo "$sanitized_content" | sed 's/ftp[^ ]*//g')
    sanitized_content=$(handle_home_folder_expansion "$sanitized_content")
    echo "$sanitized_content"
}

#handle ~ home expansion
handle_home_folder_expansion() {
    files=$(echo "$1" | sed "s/~/\$HOME/g")
    echo "$files"
}
