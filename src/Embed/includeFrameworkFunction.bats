#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Embed/includeFrameworkFunction.sh
source "${srcDir}/Embed/includeFrameworkFunction.sh"
# shellcheck source=src/Embed/extractFileFromMd5.sh
source "${srcDir}/Embed/extractFileFromMd5.sh"
# shellcheck source=src/Env/pathPrepend.sh
source "${srcDir}/Env/pathPrepend.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${ROOT_DIR}"
  export PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
}

function Embed::includeFrameworkFunction { #@test
  local -a _EMBED_COMPILE_ARGUMENTS=(
    # templateDir : directory from which bash-tpl templates will be searched
    --template-dir "${srcDir}/_includes"
    # binDir      : fallback bin directory in case BIN_FILE has not been provided
    --bin-dir "${BATS_TEST_TMPDIR}"
    # rootDir     : directory used to compute src file relative path
    --root-dir "${ROOT_DIR}"
    # srcDirs : (optional) you can provide multiple directories
    --src-dir "${srcDir}"
  )

  Embed::includeFrameworkFunction \
    "Filters::bashFrameworkFunctions" \
    "bashFrameworkFunctions" \
    >"${BATS_TEST_TMPDIR}/functionIncluded"

  export PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
  export TMPDIR="${BATS_TEST_TMPDIR}"
  # shellcheck disable=SC2031
  export KEEP_TEMP_FILES=1

  # shellcheck source=/dev/null
  source "${BATS_TEST_TMPDIR}/functionIncluded"

  # shellcheck disable=SC2154
  [[ -x "${embed_function_BashFrameworkFunctions}" ]]
  [[ "$(basename "${embed_function_BashFrameworkFunctions}")" = "bashFrameworkFunctions" ]]
  [[ ":${PATH}:" = *":$(dirname "${embed_function_BashFrameworkFunctions}"):"* ]]

  command -v bashFrameworkFunctions || return 1
  bashFrameworkFunctions \
    "${BATS_TEST_DIRNAME}/testsData/includeFrameworkFunction.txt" \
    >"${BATS_TEST_TMPDIR}/includeFrameworkFunction.result.txt"

  diff \
    "${BATS_TEST_TMPDIR}/includeFrameworkFunction.result.txt" \
    "${BATS_TEST_DIRNAME}/testsData/includeFrameworkFunction.expected.txt"
}
