#!/usr/bin/env bash

# @description cut a string by a given separator and add each element to
# an array passed by reference
# @example
#   Array::setArray arr , "1,2,3,"
#   declare -p arr
#       # output: declare -a arr=([0]="1" [1]="2" [2]="3")
#   Array::setArray path : "$PATH"
#   Array::setArray ld_preload ': ' "$LD_PRELOAD" # its elements can be separated by either ':' or spaces
# @arg $1 setArray_array:&String[] (passed by reference) the array to update
# @arg $2 sep:String the separator to use
# @arg $3 elements:String the list of elements to cut by sep and to add to the array
# @see https://unix.stackexchange.com/a/520062
Array::setArray() {
  local -n setArray_array=$1
  local IFS=$2 -
  # set no glob feature
  set -f
  # shellcheck disable=SC2206,SC2034
  setArray_array=($3)
}
