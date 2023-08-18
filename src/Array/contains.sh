#!/usr/bin/env bash

# @description check if an element is contained in an array
#
# @arg $1 needle:String
# @arg $@ array:String[]
# @exitcode 0 if found
# @exitcode 1 otherwise
# @example
#   Array::contains "${libPath}" "${__BASH_FRAMEWORK_IMPORTED_FILES[@]}"
Array::contains() {
  local element
  for element in "${@:2}"; do
    [[ "${element}" = "$1" ]] && return 0
  done
  return 1
}
