#!/usr/bin/env bash

# @description concat each element of an array with a separator
#
# @arg $1 glue:String
# @arg $@ array:String[]
# @example
#  declare -a array=(test1, test2)
#  echo "Result= $(Array::join "," "${array[@]})"
#  Result= test1,test2
Array::join() {
  local glue="${1-}"
  shift || true
  local first="${1-}"
  shift || true
  printf %s "${first}" "${@/#/${glue}}"
}
