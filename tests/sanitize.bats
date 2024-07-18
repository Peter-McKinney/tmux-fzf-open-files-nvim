#!/usr/bin/env bats

. "$BATS_TEST_DIRNAME/../scripts/sanitize.sh"

@test "handle home folder expansion" {
    result="$(handle_home_folder_expansion "~/something/readme.md")"
    [ "$result" = "\$HOME/something/readme.md" ]
}

@test "remove_http_ftp should remove http urls" {
    result="$(remove_http_ftp "https://github.com")"
    echo "$result"
    [ "$result" = "" ]
}

@test "remove_http_ftp should remove ftp urls" {
    result="$(remove_http_ftp "ftp://github.com")"
    echo "$result"
    [ "$result" = "" ]
}
