#!/usr/bin/env bash

# Internal: source given file.
# Do not source it again if it has already been sourced.
# try to source relative path from each lib path
#
# **Arguments**:
# * $1 file to source
#
# **Exit**: code 1 if error while sourcing
Framework::sourcePathOnce() {
  local libPath="$1"
  shift
  if [[ -z "${libPath}" ]]; then
    return
  fi

  # echo trying ${libPath}
  if [[ -d "${libPath}" ]]; then
    local file
    for file in "${libPath}"/*.sh; do
      Framework::SourceFile "${file}" "$@"
    done
  else
    Framework::SourceFile "${libPath}" "$@" || Framework::SourceFile "${libPath}.sh" "$@"
  fi
}
