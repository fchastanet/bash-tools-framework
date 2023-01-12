#!/usr/bin/env bash

# Fail and display details if `$lines` does not match the expected
# number of lines.
#
# Globals:
#   lines
# Options:
#   none
# Arguments:
#   $1 - expected number of lines
# Returns:
#   0 - expected matches the actual output
#   1 - otherwise
# Inputs:
#   None
# Outputs:
#   STDERR - details, on failure
#            error message, on error
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
