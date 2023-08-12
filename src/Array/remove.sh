#!/usr/bin/env bash

# @description remove elements from array
# @arg $1 arrayRemoveArray:&String[] (reference) array from which elements have to be removed
# @arg $@ valuesToRemoveKeys:String[] list of elements to remove
# @warning Performance1 : version taken from https://stackoverflow.com/a/59030460
# @warning Performance2 : for multiple values to remove, prefer using Array::removeIf
# @see Array::removeIf
Array::remove() {
  local -n arrayRemoveArray=$1
  shift || true # $@ contains elements to remove
  local -A valuesToRemoveKeys=()

  # Tag items to remove
  local del
  for del in "$@"; do valuesToRemoveKeys[${del}]=1; done

  # remove items
  local k
  for k in "${!arrayRemoveArray[@]}"; do
    if [[ -n "${valuesToRemoveKeys[${arrayRemoveArray[k]}]+xxx}" ]]; then
      unset 'arrayRemoveArray[k]'
    fi
  done

  # compaction (element re-indexing, because unset makes "holes" in array )
  arrayRemoveArray=("${arrayRemoveArray[@]}")
}
