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

@test "parse_files matches grep-style line-only suffix" {
  result="$(echo "src/utils/parser.go:42:found a match" | parse_files)"
  [ "$result" = "src/utils/parser.go:42" ]
}

@test "parse_files matches ripgrep output with line-only suffix" {
  result="$(echo "path/to/file.rs:128:    let x = 1;" | parse_files)"
  [ "$result" = "path/to/file.rs:128" ]
}

@test "parse_files still matches line:col compiler error suffix" {
  result="$(echo "error: src/main.c:42:5: undeclared identifier" | parse_files)"
  [ "$result" = "src/main.c:42:5" ]
}

@test "parse_files matches mypy-style line-only error output" {
  result="$(echo "app/models/user.py:17: error: Incompatible return value" | parse_files)"
  [ "$result" = "app/models/user.py:17" ]
}

@test "parse_files matches make-style line-only error output" {
  result="$(echo "build/Makefile.in:10: *** missing separator." | parse_files)"
  [ "$result" = "build/Makefile.in:10" ]
}

@test "parse_files matches js stack trace with line-only suffix" {
  result="$(echo "    at processTicks /usr/lib/node_modules/foo/index.js:95" | parse_files)"
  [ "$result" = "/usr/lib/node_modules/foo/index.js:95" ]
}

@test "parse_files matches multiple files with mixed suffix styles" {
  result="$(echo "a/b/one.ts:10 a/b/two.ts:20:5 a/b/three.ts" | parse_files)"
  expected="a/b/one.ts:10
a/b/two.ts:20:5
a/b/three.ts"
  [ "$result" = "$expected" ]
}

@test "parse_files does not consume trailing non-numeric text as line suffix" {
  result="$(echo "lib/foo.js:abc" | parse_files)"
  [ "$result" = "lib/foo.js" ]
}

@test "remove invalid characters" {
  result="$(echo "(&&here/is-dashes-in-name/a/file.txt)" | remove_invalid_characters)"
  [ "$result" = "here/is-dashes-in-name/a/file.txt" ]
}

@test "remove invalid characters quotes" {
  result="$(echo "\"\"(&&here/is-dashes-in-name/a/file.txt)" | remove_invalid_characters)"
  [ "$result" = "here/is-dashes-in-name/a/file.txt" ]
}
