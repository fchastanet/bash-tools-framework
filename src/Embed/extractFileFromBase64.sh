#!/usr/bin/env bash

# convert base64 encoded back to target file
# if target file is executable prepend dir of target
# file to PATH to make binary available everywhere
# @param {string} targetFile $1 the file to write
# it is advised to include in the path of the target file
# the md5sum of the binFile
# @param {string} binFileBase64 $2 the base64 encoded file
# @param {string} fileMode $3 the chmod to set on the file
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
