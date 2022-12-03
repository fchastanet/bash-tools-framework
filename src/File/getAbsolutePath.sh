#!/usr/bin/env bash

# Public: get absolute file from relative path
#
# **Arguments**:
# * $1 relative file path
#
# **Output**: absolute path (can be $1 if $1 begins with /)
File::getAbsolutePath() {
  # http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
  # $1 : relative filename
  local file="$1"
  if [[ "${file}" == "/"* ]]; then
    echo "${file}"
  else
    echo "$(cd "$(dirname "${file}")" && pwd)/$(basename "${file}")"
  fi
}
