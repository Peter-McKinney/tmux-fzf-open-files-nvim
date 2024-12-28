#!/usr/bin/env bats

load scripts/file_strings_to_nvim.sh

@test "should return files tabedit with line numbers" {
  result="$(to_tabedit_strings "/home/somefile.ts
  /home/file-with_ln:13:536")"
  expected_result="tabedit /home/somefile.ts | tabedit +call\ cursor(13,536) /home/file-with_ln |"

  result=$(echo "$result" | xargs)
  expected_result=$(echo "$expected_result" | xargs)

  [ "$result" = "$expected_result" ]
}
