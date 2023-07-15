#!/usr/bin/env bash

rootDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
vendorDir="${rootDir}/vendor"

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Embed/includeFrameworkFunction.sh
source "${BATS_TEST_DIRNAME}/includeFrameworkFunction.sh"

# shellcheck source=src/Env/pathPrepend.sh
source "${rootDir}/src/Env/pathPrepend.sh"

setup() {
  export TMPDIR="${BATS_RUN_TMPDIR}"
}

function Embed::includeFrameworkFunction { #@test
  declare -agx CONSTRUCT_BIN_FILE_ARGUMENTS=(
    # srcFile     : file that needs to be compiled
    "" # any value will be replaced by the generated file
    # templateDir : directory from which bash-tpl templates will be searched
    "${rootDir}/src/_includes"
    # binDir      : fallback bin directory in case BIN_FILE has not been provided
    "${BATS_TMP_DIR}"
    # rootDir     : directory used to compute src file relative path
    "${rootDir}"
    # srcDirs : (optional) you can provide multiple directories
    "${rootDir}/src"
  )
  (
    echo "#!/bin/bash"
    Embed::includeFrameworkFunction "Filters::bashFrameworkFunctions" "bashFrameworkFunctions"
  ) >"${BATS_RUN_TMPDIR}/functionIncluded"
  # shellcheck source=/dev/null
  source "${BATS_RUN_TMPDIR}/functionIncluded"

  run bashFrameworkFunctions "${BATS_TEST_DIRNAME}/testsData/includeFrameworkFunction.txt"

  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/includeFrameworkFunction.txt")"
  [[ -x "${BATS_RUN_TMPDIR}/bin/bashFrameworkFunctions" ]]
  # shellcheck disable=SC2154
  [[ "${embed_function_bashFrameworkFunctions}" = "${BATS_RUN_TMPDIR}/bin/bashFrameworkFunctions" ]]
  [[ ":${PATH}:" = *":${BATS_RUN_TMPDIR}/bin:"* ]]
}
