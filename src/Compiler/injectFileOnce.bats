#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

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
  Compiler::injectFileOnce "${BATS_TEST_DIRNAME}/testsData/var1.sh" filesImported \
    >"${BATS_TEST_TMPDIR}/output" || status=$?
  [[ "${status}" = "0" ]]
  [[ "$(cat "${BATS_TEST_TMPDIR}/output")" = "# VAR_VAR=VALUE" ]]
  [[ "${#filesImported[@]}" = "1" ]]
  [[ "${filesImported[0]}" = "${BATS_TEST_DIRNAME}/testsData/var1.sh" ]]
}

function Compiler::injectFileOnce::oneFileNotExists { #@test
  local -a filesImported=()
  local status=0
  Compiler::injectFileOnce "${BATS_TEST_DIRNAME}/testsData/varNotFound.sh" filesImported \
    >"${BATS_TEST_TMPDIR}/output" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "$(cat "${BATS_TEST_TMPDIR}/output")" = *"Import ${BATS_TEST_DIRNAME}/testsData/varNotFound.sh does not exist"* ]]
  [[ "${#filesImported[@]}" = "0" ]]
}
