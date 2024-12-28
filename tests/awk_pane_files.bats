#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/../scripts/awk_pane_files.sh"

@test "parse_files should return a file path" {
    result="$(parse_files "something more text here/is/a/file.txt more text")"
    [ "$result" = "here/is/a/file.txt" ]
}

@test "folder paths are ignored" {
    result="$(parse_files "something with /home/person/something/else")"
    [ "$result" = "" ]
}

@test "parse_files should return unique files only" {
    result="$(parse_files "/home/pete/file.txt
    /home/pete/file.txt
    /home/pete/file.txt
    /home/pete/file.txt")"
    [ "$result" = "/home/pete/file.txt" ]
}

@test "parse_files should return unique files only double prompt newline separated" {
    result="$(parse_files "❯ echo \"something/somethingelse.txt\"
    something/somethingelse.txt")"
    echo "$result"
    [ "$result" = "something/somethingelse.txt" ]
}

@test "remove invalid characters" {
    result="$(remove_invalid_characters "(&&here/is-dashes-in-name/a/file.txt)")"
    [ "$result" = "here/is-dashes-in-name/a/file.txt" ]
}

@test "remove invalid characters quotes" {
    result="$(remove_invalid_characters "\"\"(&&here/is-dashes-in-name/a/file.txt)")"
    [ "$result" = "here/is-dashes-in-name/a/file.txt" ]
}
