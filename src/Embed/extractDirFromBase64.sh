#!/usr/bin/env bash

# convert base64 encoded back to target dir
# @params {string} targetDir $1 the directory in which
#   tar archive will be untarred
# it is advised to include in the path of the target dir
# the md5sum of the binFile
# @params {string} base64 $2 the base64 encoded tar czf
#   archive
Embed::extractDirFromBase64() {
  local targetDir="$1"
  local base64="$2"

  if [[ ! -d "${targetDir}" ]]; then
    mkdir -p "${targetDir}"
    (
      cd "${targetDir}" || exit 1
      tar -xzf <(base64 -d <<<"${base64}") 2>/dev/null || {
        Log::displayError "untar failure, invalid base64 string"
        exit 1
      }
    ) || return 1
  fi
}
