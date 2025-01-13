#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/../scripts/awk_pane_files.sh"

@test "parse_files should return a file path" {
  result="$(echo "something more text here/is/a/file.txt more text" | parse_files)"
  [ "$result" = "here/is/a/file.txt" ]
}

@test "folder paths are ignored" {
  result="$(echo "something with /home/person/something/else" | parse_files)"
  [ "$result" = "" ]
}

@test "parse_files should return unique files only" {
  result="$(echo "/home/pete/file.txt
    /home/pete/file.txt
    /home/pete/file.txt
    /home/pete/file.txt" | parse_files)"
  [ "$result" = "/home/pete/file.txt" ]
}

@test "parse_files should return unique files only double prompt newline separated" {
  result="$(echo "❯ echo \"something/somethingelse.txt\"
    something/somethingelse.txt" | parse_files)"
  echo "$result"
  [ "$result" = "something/somethingelse.txt" ]
}

@test "remove invalid characters" {
  result="$(echo "(&&here/is-dashes-in-name/a/file.txt)" | remove_invalid_characters)"
  [ "$result" = "here/is-dashes-in-name/a/file.txt" ]
}

@test "remove invalid characters quotes" {
  result="$(echo "\"\"(&&here/is-dashes-in-name/a/file.txt)" | remove_invalid_characters)"
  [ "$result" = "here/is-dashes-in-name/a/file.txt" ]
}
