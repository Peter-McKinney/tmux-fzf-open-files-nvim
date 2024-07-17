#!/usr/bin/env bash

parse_files() {
    # awk for anything that resembles a file path with a file extension on the end.
    # only return unique paths
    files=$(echo "$1" | awk '{
    while (match($0, /[^[:space:]]*\/[[:alnum:]._-]+(\/[[:alnum:]._-]+)*\.[[:alnum:]]+/)) {
        path = substr($0, RSTART, RLENGTH)
        if (!seen[path]++) {
            print path
        }
        $0 = substr($0, RSTART + RLENGTH)
    }
    }')

    #handle ~ home expansion
    files=$(echo "$files" | sed 's/~/\$HOME/g')

    echo "$files"
}
