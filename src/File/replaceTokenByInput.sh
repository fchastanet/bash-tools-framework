#!/usr/bin/env bash

# @description replace token by input(stdin) in given targetFile
# @warning special ansi codes will be removed from stdin
# @arg $1 token:String the token to replace by stdin
# @arg $2 targetFile:String the file in which token will be replaced by stdin
# @exitcode 1 if error
# @stdin the file content that will be injected in targetFile
File::replaceTokenByInput() {
  local token="$1"
  local targetFile="$2"

  (
    local tokenFile
    tokenFile="$(Framework::createTempFile "replaceTokenByInput")"

    cat - | Filters::removeAnsiCodes >"${tokenFile}"
    # ensure blank final line
    echo >>"${tokenFile}"

    sed -E -i \
      -e "/${token}/r ${tokenFile}" \
      -e "/${token}/d" \
      "${targetFile}"
  )
}
