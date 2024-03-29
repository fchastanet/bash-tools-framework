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

  infoMsg=$(Log::displayInfo "info" 2>&1)
  expectedInfoMsg="$(echo -e "${__INFO_COLOR}INFO    - info${__RESET_COLOR}")"
}

function Log::displayInfo::debugLevel { #@test
  generateLogs "Log.debug.env"
  [[ "${infoMsg}" == "${expectedInfoMsg}" ]]
}

function Log::displayInfo::infoLevel { #@test
  generateLogs "Log.info.env"
  [[ "${infoMsg}" == "${expectedInfoMsg}" ]]
}

function Log::displayInfo::successLevel { #@test
  generateLogs "Log.success.env"
  [[ "${infoMsg}" == "${expectedInfoMsg}" ]]
}

function Log::displayInfo::warningLevel { #@test
  generateLogs "Log.warning.env"
  [[ -z "${infoMsg}" ]]
}

function Log::displayInfo::errorLevel { #@test
  generateLogs "Log.error.env"
  [[ -z "${infoMsg}" ]]
}

function Log::displayInfo::offLevel { #@test
  generateLogs "Log.off.env"
  [[ -z "${infoMsg}" ]]
}
