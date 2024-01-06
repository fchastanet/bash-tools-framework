#!/usr/bin/env bash

# @description convert base64 encoded back to target dir
# it is advised to include the md5sum of the binFile in the path of the target dir
#
# @arg $1 targetDir:string the directory in which tar archive will be untarred
# @arg $2 base64:string the base64 encoded tar czf archive
# @stderr diagnostics information is displayed
# @require Linux::requireTarCommand
Compiler::Embed::extractDirFromBase64() {
  local targetDir="$1"
  local base64="$2"

  if [[ ! -d "${targetDir}" ]]; then
    mkdir -p "${targetDir}"
    (
      cd "${targetDir}" || exit 1
      base64 -d <<<"${base64}" | tar -xzf - 2>/dev/null || {
        Log::displayError "untar failure, invalid base64 string"
        exit 1
      }
    ) || return 1
  fi
}
