#!/usr/bin/env bash

# Public: search a file in parent directories
#
# **Arguments**:
# * $1 path
# * $2 fileName
# * $@ list of untilInclusivePath
# **Output**: The filename if found
# **Exit**: code 1 if the command failed
File::upFind() {
  local fromPath="$1"
  shift || true
  local fileName="$1"
  shift || true
  local untilInclusivePath="${1:-/}"
  shift || true

  if [[ -f "${fromPath}" ]]; then
    fromPath="$(dirname "${fromPath}")"
  fi
  while true; do
    if [[ -f "${fromPath}/${fileName}" ]]; then
      echo "${fromPath}/${fileName}"
      return 0
    fi
    if Array::contains "${fromPath}" "${untilInclusivePath}" "$@" "/"; then
      return 1
    fi
    fromPath="$(readlink -f "${fromPath}"/..)"
  done
  return 1
}
