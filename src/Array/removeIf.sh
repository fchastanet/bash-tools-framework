#!/usr/bin/env bash

# @description more performant version of Array:remove
# remove elements from array using a predicate function
# @example
#   function predicateElem1to5() {
#     [[ "$1" =~ ^elem[1-5]$ ]] || return 1
#   }
#   local -a myArray=("elem1" "elemX" "elem2" "elemX" "elem3" "elemX" "elem4" "elemX" "elem5" "elemX")
#   Array::removeIf myArray predicateElem1to5
#   echo "${myArray[*]}"
#   # Result: elemX elemX elemX elemX elemX
#
# @arg $1 arrayRemoveArray:&String[] (reference) array from which elements have to be removed
# @arg $2 predicateFunction:Function callback function called on each element
# @exitcode 1 if predicateFunction argument is not a function or empty
# @see Array::remove
Array::removeIf() {
  local -n arrayRemoveArray=$1
  # shellcheck disable=SC2034
  local predicateFunction=$2
  if [[ -z "${predicateFunction}" || "$(type -t "${predicateFunction}")" != "function" ]]; then
    return 1
  fi

  local key
  for key in "${!arrayRemoveArray[@]}"; do
    if ${predicateFunction} "${arrayRemoveArray[${key}]}"; then
      unset "arrayRemoveArray[key]"
    fi
  done
  arrayRemoveArray=("${arrayRemoveArray[@]}")
}
