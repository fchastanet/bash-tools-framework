#!/usr/bin/env bash

Embed::includeFrameworkFunction() {
  local functionToCall="$1"
  local functionAlias="$2"
  local currentDir
  local rootDir
  currentDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd -P)"
  rootDir="$(cd "${currentDir}/../.." && pwd -P)"

  (
    trap 'rm -Rf "${binSrcFile}" "${binFile}" >/dev/null 2>&1' EXIT HUP QUIT ABRT TERM
    # create binfile
    binSrcFile="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-includeFrameworkFunction-XXXXXX)"
    binFile="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-includeFrameworkFunction-XXXXXX)"

    # generate bin src file content
    # shellcheck disable=SC2016
    asName="${functionAlias}" \
      functionToCall="${functionToCall}" \
      ORIGINAL_TEMPLATE_DIR='${ORIGINAL_TEMPLATE_DIR}' \
      BIN_FILE="${binFile}" \
      envsubst <"${currentDir}/includeFrameworkFunction.binFile.tpl" \
      >"${binSrcFile}"

    # compile the bin file
    "${rootDir}/bin/constructBinFile" "${binSrcFile}" "${CONSTRUCT_BIN_FILE_ARGUMENTS[@]:1}"

    # encode bin file as md5
    md5="$(base64 -w 0 "${binFile}")" \
    asName="${functionAlias}" \
    functionToCall="${functionToCall}" \
    targetFile="\${TMPDIR}/bin/${functionAlias}" \
      envsubst <"${currentDir}/includeFrameworkFunction.tpl"
  )
}
