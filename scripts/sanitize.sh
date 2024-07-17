sanitize_pane_output() {
    # remove http or ftp urls.
    sanitized_content=$(remove_invalid_path_characters "$1")
    sanitized_content=$(echo "$sanitized_content" | sed 's/http[^ ]*//g')
    sanitized_content=$(echo "$sanitized_content" | sed 's/ftp[^ ]*//g');
    echo "$sanitized_content"
}

# remove any characters that are not valid in a file path
remove_invalid_path_characters() {
    echo "$1" | awk '{ gsub(/[^[:alnum:][:space:]._~\/-]/, ""); print }'
}
