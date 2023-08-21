#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Log/requireLoad.sh
source "${srcDir}/Log/requireLoad.sh"

setup() {
  rm -f "${BATS_TEST_TMPDIR}/logFile" || true
}

teardown() {
  unstub_all
}

function Log::requireLoad::logFileNotProvided { #@test
  export BASH_FRAMEWORK_LOG_LEVEL="${__LEVEL_INFO}"
  unset BASH_FRAMEWORK_LOG_FILE
  local status=0
  Log::rotate() {
    # shouldn't be called
    return 1
  }
  Log::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "${__LEVEL_OFF}" ]]
}

function Log::requireLoad::logDirectoryNotWritable { #@test
  export BASH_FRAMEWORK_LOG_LEVEL="${__LEVEL_INFO}"
  export BASH_FRAMEWORK_LOG_FILE="/mydir/logFile"
  local status=0
  Log::rotate() {
    # shouldn't be called
    return 1
  }
  Log::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output --partial "ERROR   - File /mydir/logFile is not writable"
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "${__LEVEL_OFF}" ]]
}

function Log::requireLoad::logFileNotWritable { #@test
  export BASH_FRAMEWORK_LOG_LEVEL="${__LEVEL_INFO}"
  export BASH_FRAMEWORK_LOG_FILE="${BATS_TEST_TMPDIR}/logFile"
  touch "${BATS_TEST_TMPDIR}/logFile"
  chmod 444 "${BATS_TEST_TMPDIR}/logFile"
  local status=0
  Log::rotate() {
    # shouldn't be called
    return 1
  }
  Log::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output --partial "ERROR   - File ${BATS_TEST_TMPDIR}/logFile is not writable"
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "${__LEVEL_OFF}" ]]
}

function Log::requireLoad::logFileWritable { #@test
  export BASH_FRAMEWORK_LOG_LEVEL="${__LEVEL_INFO}"
  export BASH_FRAMEWORK_LOG_FILE="${BATS_TEST_TMPDIR}/logFile"
  export BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=0
  local status=0
  stub date '* : echo date'
  Log::rotate() {
    # shouldn't be called
    return 1
  }
  Log::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "${__LEVEL_INFO}" ]]
  run cat "${BATS_TEST_TMPDIR}/logFile"
  assert_output "date|   INFO|Logging to file ${BATS_TEST_TMPDIR}/logFile - Log level 3"
}

function Log::requireLoad::logFileWritableLogRotate { #@test
  export BASH_FRAMEWORK_LOG_LEVEL="${__LEVEL_INFO}"
  export BASH_FRAMEWORK_LOG_FILE="${BATS_TEST_TMPDIR}/logFile"
  export BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=1
  local status=0
  stub date '* : echo date'
  Log::rotate() {
    echo "Log::rotate"
    return 0
  }
  Log::requireLoad >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output "Log::rotate"
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" = "${__LEVEL_INFO}" ]]
  run cat "${BATS_TEST_TMPDIR}/logFile"
  assert_output "date|   INFO|Logging to file ${BATS_TEST_TMPDIR}/logFile - Log level 3"
}
