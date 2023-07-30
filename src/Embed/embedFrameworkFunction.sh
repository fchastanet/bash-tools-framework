#!/usr/bin/env bash

# Allows to generate a bin file that will call the mentioned
# bash framework function(md5 encoded) wrapped in an extractor
# function
# Note:
#   You cannot call this function directly
#   it should be called using '# EMBED ... AS ...' annotation
# @param {string} functionToCall $1
# @param {string} functionAlias $2
# @output the generated bin file extractor
#   this bin file extractor actually calls a function that will
#   extract the real binFile(md5 encoded) that
# @env _EMBED_COMPILE_ARGUMENTS allows to override default compile arguments
# declare -a _EMBED_COMPILE_ARGUMENTS=(
#      # templateDir : directory from which bash-tpl templates will be searched
#      --template-dir "${_COMPILE_SRC_DIR}/_includes"
#      # binDir      : fallback bin directory in case BIN_FILE has not been provided
#      --bin-dir "${_COMPILE_BIN_DIR}"
#      # rootDir     : directory used to compute src file relative path
#      --root-dir "${_COMPILE_ROOT_DIR}"
#      # srcDirs : (optional) you can provide multiple directories
#      --src-dir "${_COMPILE_SRC_DIR}"
# )
# @env _COMPILE_ROOT_DIR
# @env PERSISTENT_TMPDIR to avoid directory to be deleted by traps
Embed::embedFrameworkFunction() {
  local functionToCall="$1"
  local functionAlias="$2"

  (
    export KEEP_TEMP_FILES=1

    # create binFile
    binSrcFile="$(mktemp -p "${TMPDIR:-/tmp}" \
      -t bash-tools-embedFrameworkFunction-binSrcFile-XXXXXX)"
    binFileExtractor="$(mktemp -p "${TMPDIR:-/tmp}" \
      -t bash-tools-embedFrameworkFunction-binFileExtractor-XXXXXX)"

    # generate bin src file content
    (
      export functionToCall
      # shellcheck disable=SC2016
      export ORIGINAL_TEMPLATE_DIR='${ORIGINAL_TEMPLATE_DIR}'
      functionToCall="${functionToCall}" \
        "${_COMPILE_ROOT_DIR}/bin/compile" \
        --bin-file "${binSrcFile}" \
        "${_EMBED_COMPILE_ARGUMENTS[@]}" \
        "${_COMPILE_ROOT_DIR}/src/Embed/embedFrameworkFunction.binFile.tpl"
    )

    # compute binFile md5 checksum to allow multiple binary with different file versions
    # to run in parallel
    binFileMd5Sum="$(md5sum "${binSrcFile}" | awk '{print $1}')"

    # encode bin file as md5
    # using PERSISTENT_TMPDIR to avoid directory to be deleted by traps
    (
      binFileMd5="$(base64 -w 0 "${binSrcFile}")" \
      targetFile="\${PERSISTENT_TMPDIR:-/tmp}/bin/${binFileMd5Sum}/${functionAlias}" \
      asName="${functionAlias^}" \
        "${_COMPILE_ROOT_DIR}/bin/compile" \
        --bin-file "${binFileExtractor}" \
        "${_EMBED_COMPILE_ARGUMENTS[@]}" \
        "${_COMPILE_ROOT_DIR}/src/Embed/embedFrameworkFunction.tpl"
    )

    cat "${binFileExtractor}"
  )
}
