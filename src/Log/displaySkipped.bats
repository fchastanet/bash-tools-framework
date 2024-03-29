#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Assert/fileWritable.sh
source "${srcDir}/Assert/fileWritable.sh"
# shellcheck source=src/Assert/validPath.sh
source "${srcDir}/Assert/validPath.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  logFile=""$(mktemp -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)""

  unset HOME
  unset FRAMEWORK_ROOT_DIR
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=0
}

teardown() {
  rm -f "${logFile}" || true
}

generateLogs() {
  local envFile="$1"
  initLogs "${envFile}"

  skippedMsg=$(Log::displaySkipped "skipped" 2>&1)
  expectedSkippedMsg="$(echo -e "${__SKIPPED_COLOR}SKIPPED - skipped${__RESET_COLOR}")"
}

function Log::displaySkipped::debugLevel { #@test
  generateLogs "Log.debug.env"
  [[ "${skippedMsg}" == "${expectedSkippedMsg}" ]]
}

function Log::displaySkipped::infoLevel { #@test
  generateLogs "Log.info.env"
  [[ "${skippedMsg}" == "${expectedSkippedMsg}" ]]
}

function Log::displaySkipped::successLevel { #@test
  generateLogs "Log.success.env"
  [[ "${skippedMsg}" == "${expectedSkippedMsg}" ]]
}

function Log::displaySkipped::warningLevel { #@test
  generateLogs "Log.warning.env"
  [[ -z "${skippedMsg}" ]]
}

function Log::displaySkipped::errorLevel { #@test
  generateLogs "Log.error.env"
  [[ -z "${skippedMsg}" ]]
}

function Log::displaySkipped::offLevel { #@test
  generateLogs "Log.off.env"
  [[ -z "${skippedMsg}" ]]
}
