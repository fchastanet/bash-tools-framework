#!/usr/bin/env bash

rootDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
srcDir="${rootDir}/src"
vendorDir="${rootDir}/vendor"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Compiler/injectFileOnce.sh
source "${BATS_TEST_DIRNAME}/injectFileOnce.sh"
# shellcheck source=/src/Array/contains.sh
source "${srcDir}/Array/contains.sh"
# shellcheck source=/src/Filters/catFileCleaned.sh
source "${srcDir}/Filters/catFileCleaned.sh"
# shellcheck source=/src/Filters/trimEmptyLines.sh
source "${srcDir}/Filters/trimEmptyLines.sh"

function Compiler::injectFileOnce::oneFile { #@test
  local -a filesImported=()
  local status=0
  Compiler::injectFileOnce "${BATS_TEST_DIRNAME}/testsData/meta1.sh" filesImported \
    >"${BATS_RUN_TMPDIR}/output" || status=$?
  [[ "${status}" = "0" ]]
  [[ "$(cat "${BATS_RUN_TMPDIR}/output")" = "# META_VAR=VALUE" ]]
  [[ "${#filesImported[@]}" = "1" ]]
  [[ "${filesImported[0]}" = "${BATS_TEST_DIRNAME}/testsData/meta1.sh" ]]
}

function Compiler::injectFileOnce::oneFileNotExists { #@test
  local -a filesImported=()
  local status=0
  Compiler::injectFileOnce "${BATS_TEST_DIRNAME}/testsData/metaNotFound.sh" filesImported \
    >"${BATS_RUN_TMPDIR}/output" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "$(cat "${BATS_RUN_TMPDIR}/output")" = *"Import ${BATS_TEST_DIRNAME}/testsData/metaNotFound.sh does not exist"* ]]
  [[ "${#filesImported[@]}" = "0" ]]
}
