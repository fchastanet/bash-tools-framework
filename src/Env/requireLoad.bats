#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Env/requireLoad.sh
source "${srcDir}/Env/requireLoad.sh"
# shellcheck source=src/Env/mergeConfFiles.sh
source "${srcDir}/Env/mergeConfFiles.sh"
# shellcheck source=src/Framework/createTempFile.sh
source "${srcDir}/Framework/createTempFile.sh"
# shellcheck source=src/Filters/commentLines.sh
source "${srcDir}/Filters/commentLines.sh"

function Env::requireLoad::getOrderedConfFilesFailure { #@test
  Env::getOrderedConfFiles() {
    return 1
  }
  local status=0
  Env::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Env::requireLoad::getOrderedConfFilesEmpty { #@test
  Env::getOrderedConfFiles() {
    return 0
  }
  local status=0
  Env::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "SKIPPED - no env file to load"
}

function Env::requireLoad::mergeConfFilesFailure { #@test
  Env::getOrderedConfFiles() {
    echo "${BATS_TEST_DIRNAME}/testsData/.env"
    return 0
  }
  Env::mergeConfFiles() {
    return 1
  }
  local status=0
  Env::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "2" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - while loading config files: ${BATS_TEST_DIRNAME}/testsData/.env"
}

function Env::requireLoad::success { #@test
  Env::getOrderedConfFiles() {
    echo "${BATS_TEST_DIRNAME}/testsData/.env"
    return 0
  }
  Env::mergeConfFiles() {
    return 0
  }
  local status=0
  Env::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Env::requireLoad::testMerge { #@test
  local status=0
  unset BASH_FRAMEWORK_LOG_LEVEL
  unset BASH_FRAMEWORK_DISPLAY_LEVEL
  unset BASH_FRAMEWORK_LOG_FILE
  unset BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION
  Env::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "0" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "2" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "${FRAMEWORK_ROOT_DIR}/logs/${SCRIPT_NAME}.log" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "5" ]]
}

function Env::requireLoad::override { #@test
  local status=0
  export BASH_FRAMEWORK_LOG_LEVEL="4"
  export BASH_FRAMEWORK_DISPLAY_LEVEL="5"
  export BASH_FRAMEWORK_LOG_FILE="logFile"
  export BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION="12"
  Env::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "4" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "5" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "logFile" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}" = "12" ]]
}
