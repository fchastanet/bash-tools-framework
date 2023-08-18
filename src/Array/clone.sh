#!/usr/bin/env bash

# @description clone the array passed as parameter
# @arg $1 arrayToClone:String name of the array to clone
# @arg $2 clonedArray:String name of the cloned array
# @set clonedArray containing the values of arrayToClone
Array::clone() {
  local arrayToClone=$1
  local clonedArray=$2
  set -- "$(declare -p "${arrayToClone}")" "${clonedArray}"
  eval "$2=${1#*=}"
}
