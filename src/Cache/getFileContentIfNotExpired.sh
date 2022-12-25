#!/usr/bin/env bash

# get file content if file not expired
# @param {String} file $1 the file to get content from
# @param {String} maxDuration $2 number of seconds after which the file is considered expired
# @output {String} the file content if not expired
# @return 1 if file does not exists
# @return 2 if file expired
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
