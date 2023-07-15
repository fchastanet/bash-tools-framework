#!/usr/bin/env bash

Embed::includeDir() {
  local dir="$1"
  local dirAlias="$2"
  local currentDir
  currentDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd -P)"

  (
    # shellcheck disable=SC2016
    md5="$(
      cd "${dir}" || exit 1
      tar -cz -O . | base64 -w 0
    )" \
    asName="${dirAlias}" \
    targetDir="\${TMPDIR}/${dirAlias}" \
      envsubst <"${currentDir}/includeDir.tpl"
  )
}
