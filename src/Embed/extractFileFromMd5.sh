#!/usr/bin/env bash

# convert md5 encoded back to target file
# prepend dir of target file to PATH to make
# binary available everywhere
# @params {string} targetFile $1 the file to write
# it is advised to include in the path of the target file
# the md5sum of the binFile
# @params {string} binFileMd5 $2 the md5 encoded file
Embed::extractFileFromMd5() {
  local targetFile="$1"
  local binFileMd5="$2"

  if [[ ! -f "${targetFile}" ]]; then
    mkdir -p "$(dirname "${targetFile}")"
    base64 -d >"${targetFile}" <<<"${binFileMd5}"
    chmod +x "${targetFile}"
  fi

  Env::pathPrepend "$(dirname "${targetFile}")"
}
