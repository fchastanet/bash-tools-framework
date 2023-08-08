#!/usr/bin/env bash

# remove elements from array
# Performance1 : version taken from https://stackoverflow.com/a/59030460
# Performance2 : for multiple values to remove, prefer using Array::removeIf
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
