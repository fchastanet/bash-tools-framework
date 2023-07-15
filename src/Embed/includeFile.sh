#!/usr/bin/env bash

Embed::includeFile() {
  local file="$1"
  local fileAlias="$2"
  local currentDir
  currentDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd -P)"

  (
    # shellcheck disable=SC2016
    md5="$(base64 -w 0 "${file}")" \
    asName="${fileAlias}" \
    fileMode="$(stat -c "%a %n" "${file}" | awk '{print $1}')" \
    targetFile="\${TMPDIR}/bin/${fileAlias}" \
      envsubst <"${currentDir}/includeFile.tpl"
  )
}
