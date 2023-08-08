#!/usr/bin/env bash

# more performant version of Array:remove
# remove elements from array using a predicate function
# @return 1 if predicateFunction argument is not a function or empty
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
