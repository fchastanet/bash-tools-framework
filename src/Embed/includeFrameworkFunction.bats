#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Embed/includeFrameworkFunction.sh
source "${srcDir}/Embed/includeFrameworkFunction.sh"
# shellcheck source=src/Embed/extractFileFromMd5.sh
source "${srcDir}/Embed/extractFileFromMd5.sh"
# shellcheck source=src/Env/pathPrepend.sh
source "${srcDir}/Env/pathPrepend.sh"

function Embed::includeFrameworkFunction { #@test
  declare -agx _COMPILE_FILE_ARGUMENTS=(
    # srcFile     : file that needs to be compiled
    "" # any value will be replaced by the generated file
    # templateDir : directory from which bash-tpl templates will be searched
    --template-dir "${srcDir}/_includes"
    # binDir      : fallback bin directory in case BIN_FILE has not been provided
    --bin-dir "${BATS_RUN_TMPDIR}"
    # rootDir     : directory used to compute src file relative path
    --root-dir "${ROOT_DIR}"
    # srcDirs : (optional) you can provide multiple directories
    --src-dir "${srcDir}"
  )

  Embed::includeFrameworkFunction \
    "Filters::bashFrameworkFunctions" \
    "bashFrameworkFunctions" \
    >"${BATS_RUN_TMPDIR}/functionIncluded"

  export PERSISTENT_TMPDIR="${BATS_RUN_TMPDIR}"
  export TMPDIR="${BATS_RUN_TMPDIR}"
  # shellcheck disable=SC2031
  export KEEP_TEMP_FILES=1

  # shellcheck source=/dev/null
  source "${BATS_RUN_TMPDIR}/functionIncluded"

  # shellcheck disable=SC2154
  [[ -x "${embed_function_BashFrameworkFunctions}" ]]
  [[ "$(basename "${embed_function_BashFrameworkFunctions}")" = "bashFrameworkFunctions" ]]
  [[ ":${PATH}:" = *":$(dirname "${embed_function_BashFrameworkFunctions}"):"* ]]

  command -v bashFrameworkFunctions || return 1
  bashFrameworkFunctions \
    "${BATS_TEST_DIRNAME}/testsData/includeFrameworkFunction.txt" \
    >"${BATS_RUN_TMPDIR}/includeFrameworkFunction.result.txt"

  diff \
    "${BATS_RUN_TMPDIR}/includeFrameworkFunction.result.txt" \
    "${BATS_TEST_DIRNAME}/testsData/includeFrameworkFunction.expected.txt"
}
