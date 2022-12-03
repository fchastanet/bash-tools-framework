#!/usr/bin/env bash

# check if an element is contained in an array
#
# **Arguments**:
# $@ - first parameter is the needle, rest is the array
#
# **Examples**:
#
# ```shell
#  Array::contains "${libPath}" "${__BASH_FRAMEWORK_IMPORTED_FILES[@]}"
# ```
#
# Returns 0 if found, 1 otherwise
Array::contains() {
  local element
  for element in "${@:2}"; do
    [[ "${element}" = "$1" ]] && return 0
  done
  return 1
}
