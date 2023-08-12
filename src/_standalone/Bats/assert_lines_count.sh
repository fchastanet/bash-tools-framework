#!/usr/bin/env bash

# @description Fail and display details if `$lines` does not match the expected
# number of lines.
#
# Globals:
#   lines
# @arg $1 expected:int expected number of lines
#
# @exitcode 0 - expected matches the actual output
# @exitcode 1 - otherwise
#
# @stderr details, on failure
assert_lines_count() {
  local -i expected=$1
  #shellcheck disable=SC2154
  if [[ "${#lines[@]}" != "$1" ]]; then
    echo "Invalid lines count: ${#lines[@]} (expected: \`${expected}\`)" |
      batslib_decorate 'ERROR: assert_output' |
      fail
    return 1
  fi
}
