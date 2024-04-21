#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Assert/fileWritable.sh
source "${srcDir}/Assert/fileWritable.sh"
# shellcheck source=src/Assert/validPath.sh
source "${srcDir}/Assert/validPath.sh"

declare logFile
setup() {
  logFile="$(mktemp -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_DEBUG}
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
}

teardown() {
  rm -f "${logFile}"* || true
}

function Log::rotate::noLogFile { #@test
  run Log::rotate "${BATS_TEST_TMPDIR}/unknownLogFile" "1"
  assert_success
  assert_output --partial "DEBUG  - Log file ${BATS_TEST_TMPDIR}/unknownLogFile doesn't exist yet"
}

function Log::rotate::oneLogFile { #@test
  run Log::rotate "${logFile}" "0"
  assert_success
  assert_output --partial "INFO    - Log rotation ${logFile} to ${logFile}.1"
  [[ -f "${logFile}" ]] # logFile still exists because it has been recreated by logInfo
  [[ -f "${logFile}.1" ]]
  [[ ! -f "${logFile}.2" ]]
}

function Log::rotate::twoLogFiles { #@test
  echo "logFile" >"${logFile}"
  echo "logFile.1" >"${logFile}.1"
  run Log::rotate "${logFile}" "2"
  assert_success
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Log rotation ${logFile}.1 to ${logFile}.2"
  assert_line --index 1 --partial "INFO    - Log rotation ${logFile} to ${logFile}.1"
  [[ -f "${logFile}" ]] # logFile still exists because it has been recreated by logInfo
  [[ -f "${logFile}.1" ]]
  [[ -f "${logFile}.2" ]]
  [[ ! -f "${logFile}.3" ]]
  grep -E '^logFile$' "${logFile}.1"
  grep -E '^logFile\.1$' "${logFile}.2"
}
