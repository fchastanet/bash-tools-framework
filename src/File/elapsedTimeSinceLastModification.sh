#!/usr/bin/env bash

# @description get number of seconds since last modification of the file
# @arg $1 file:String file path
# @exitcode 1 if file does not exist
# @stdout number of seconds since last modification of the file
File::elapsedTimeSinceLastModification() {
  local file="$1"
  if [[ ! -f "${file}" ]]; then
    return 1
  fi
  local lastModificationTimeSeconds diff
  lastModificationTimeSeconds="$(stat -c %Y "${file}")"
  ((diff = $(date +%s) - lastModificationTimeSeconds))
  echo -n "${diff}"
}
