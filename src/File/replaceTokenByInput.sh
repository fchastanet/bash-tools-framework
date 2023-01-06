#!/usr/bin/env bash

File::replaceTokenByInput() {
  local token="$1"
  local targetFile="$2"

  (
    local tokenFile
    tokenFile="$(Framework::createTempFile "replaceTokenByInput")"

    cat - | Filters::escapeColorCodes >"${tokenFile}"

    sed -E -i \
      -e "/${token}/r ${tokenFile}" \
      -e "/${token}/d" \
      "${targetFile}"
  )
}
