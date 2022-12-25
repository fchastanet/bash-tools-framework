#!/usr/bin/env bash

# Number of seconds since last modification of the file
# @param {String} file $1 file path
# @return 1 if file does not exist
# @output number of seconds since last modification of the file
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
