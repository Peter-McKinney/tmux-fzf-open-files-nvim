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

@test "sanitize_pane_output should remove parens" {
    input="(node_modules/jest-mock/build/index.js:839:25"

    expected_result="node_modules/jest-mock/build/index.js:839:25"

    result="$(sanitize_pane_output "$input")"
    echo "$result"
    echo "$expected_result"
    [ "$result" = "$expected_result" ]
}
