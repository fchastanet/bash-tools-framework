#!/usr/bin/env bash

# @description search a file in parent directories
#
# @arg $1 fromPath:String path
# @arg $2 fileName:String
# @arg $3 untilInclusivePath:String (optional) find for given file until reaching this folder (default value: /)
# @arg $@ untilInclusivePaths:String[] list of untilInclusivePath
# @stdout The filename if found
# @exitcode 1 if the command failed or file not found
File::upFind() {
  local fromPath="$1"
  shift || true
  local fileName="$1"
  shift || true
  local untilInclusivePath="${1:-/}"
  shift || true

  if [[ -f "${fromPath}" ]]; then
    fromPath="${fromPath%/*}"
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
