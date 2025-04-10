#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Env/requireLoad.sh
source "${srcDir}/Env/requireLoad.sh"

function Env::requireLoad::success { #@test
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
  SCRIPT_NAME="myScript"
  Env::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "0" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "3" ]]
  [[ "${BASH_FRAMEWORK_LOG_FILE}" = "${FRAMEWORK_ROOT_DIR}/logs/myScript.log" ]]
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
