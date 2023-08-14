#!/usr/bin/env bash

# @description convert base64 encoded back to target file
# if target file is executable prepend dir of target
# file to PATH to make binary available everywhere
# it is advised to include in the path of the target file
# the md5sum of the binFile
#
# @arg $1 targetFile:String the file to write
# @arg $2 binFileBase64:String the base64 encoded file
# @arg $3 fileMode:String the chmod to set on the file
# @set PATH String prepend target embedded file binary directory to PATH variable if binary executable
Embed::extractFileFromBase64() {
  local targetFile="$1"
  local binFileBase64="$2"
  local fileMode="${3:-+x}"

  if [[ ! -f "${targetFile}" ]]; then
    mkdir -p "$(dirname "${targetFile}")"
    base64 -d >"${targetFile}" <<<"${binFileBase64}"
    chmod "${fileMode}" "${targetFile}"
  fi

  if [[ -x "${targetFile}" ]]; then
    Env::pathPrepend "$(dirname "${targetFile}")"
  fi
}
