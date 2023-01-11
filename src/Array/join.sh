#!/usr/bin/env bash

# concat each element of an array with a separator
#
# **Arguments**:
# $1 - glue string
# $@ - rest is the array
#
# **Examples**:
#
# ```shell
#  declare -a array=(test1, test2)
#  echo "Result= $(Array::join "," "${array[@]})"
#  Result= test1,test2
# ```
#
# Returns 0 if found, 1 otherwise
Array::join() {
  local glue="${1-}"
  shift || true
  local first="${1-}"
  shift || true
  printf %s "${first}" "${@/#/${glue}}"
}
