#!/usr/bin/env bash

# @description get file content if file not expired
# @arg $1 file:String the file to get content from
# @arg $2 maxDuration:int number of seconds after which the file is considered expired
# @stdout {String} the file content if not expired
# @exitcode 1 if file does not exists
# @exitcode 2 if file expired
Cache::getFileContentIfNotExpired() {
  local file="$1"
  local maxDuration="$2"

  if [[ ! -f "${file}" ]]; then
    return 1
  fi
  if (($(File::elapsedTimeSinceLastModification "${file}") > maxDuration)); then
    return 2
  fi
  cat "${file}"
}
