#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/../scripts/sanitize.sh"

@test "handle home folder expansion" {
  result="$(echo "~/something/readme.md" | handle_home_folder_expansion)"
  [ "$result" = "\$HOME/something/readme.md" ]
}

@test "remove_http_ftp should remove http urls" {
  result="$(echo "https://github.com" | remove_http_ftp)"
  echo "$result"
  [ "$result" = "" ]
}

@test "remove_http_ftp should remove ftp urls" {
  result="$(echo "ftp://github.com" | remove_http_ftp)"
  echo "$result"
  [ "$result" = "" ]
}

@test "sanitize_pane_output should remove parens" {
  input="(node_modules/jest-mock/build/index.js:839:25"

  expected_result="node_modules/jest-mock/build/index.js:839:25"

  result="$(echo "$input" | sanitize_pane_output)"
  echo "$result"
  echo "$expected_result"
  [ "$result" = "$expected_result" ]
}
