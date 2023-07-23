#!/usr/bin/env bash

# Allows to generate a bin file that will call the mentionned
# bash framework function(md5 encoded) wrapped in an extractor
# function
# Note:
#   You cannot call this function directly
#   it shoult be called using '# INCLUDE ... AS ...' annotation
# @param {string} functionToCall $1
# @param {string} functionAlias $2
# @output the generated bin file extractor
#   this bin file extractor actually calls a function that will
#   extract the real binFile(md5 encoded) that
Embed::includeFrameworkFunction() {
  local functionToCall="$1"
  local functionAlias="$2"
  local currentDir
  local rootDir
  currentDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd -P)"
  rootDir="$(cd "${currentDir}/../.." && pwd -P)"

  (
    export KEEP_TEMP_FILES=1

    # create binFile
    binSrcFile="$(mktemp -p "${TMPDIR:-/tmp}" \
      -t bash-tools-includeFrameworkFunction-binSrcFile-XXXXXX)"
    binFileExtractor="$(mktemp -p "${TMPDIR:-/tmp}" \
      -t bash-tools-includeFrameworkFunction-binFileExtractor-XXXXXX)"

    # generate bin src file content
    # shellcheck disable=SC2016
    (
      export functionToCall
      export ORIGINAL_TEMPLATE_DIR='${ORIGINAL_TEMPLATE_DIR}'
      functionToCall="${functionToCall}" \
        "${rootDir}/bin/compile" \
        --bin-file "${binSrcFile}" \
        "${currentDir}/includeFrameworkFunction.binFile.tpl" \
        "${_COMPILE_FILE_ARGUMENTS[@]:1}"
    )

    # TODO do not take all arguments from _COMPILE_FILE_ARGUMENTS

    # compute binFile md5 checksum to allow multiple binary with different file versions
    # to run in parallel
    binFileMd5Sum="$(md5sum "${binSrcFile}" | awk '{print $1}')"

    # encode bin file as md5
    # using PERSISTENT_TMPDIR to avoid directory to be deleted by traps
    (
      binFileMd5="$(base64 -w 0 "${binSrcFile}")" \
      targetFile="\${PERSISTENT_TMPDIR:-/tmp}/bin/${binFileMd5Sum}/${functionAlias}" \
      asName="${functionAlias^}" \
        "${rootDir}/bin/compile" \
        "${currentDir}/includeFrameworkFunction.tpl" \
        --bin-file "${binFileExtractor}" \
        "${_COMPILE_FILE_ARGUMENTS[@]:1}"
    )

    cat "${binFileExtractor}"
  )
}
