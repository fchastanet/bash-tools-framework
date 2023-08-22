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
  local logEnvFile="$1"
  export BASH_FRAMEWORK_ENV_FILES=("${BATS_TEST_DIRNAME}/testsData/${logEnvFile}")

  Env::requireLoad
  Log::requireLoad

  statusMsg=$(Log::displayStatus "status" 2>&1)
  expectedStatusMsg="$(echo -e "${__INFO_COLOR}STATUS  - status${__RESET_COLOR}")"
}

function Log::displayStatus::debugLevel { #@test
  generateLogs "Log.debug.env"
  [[ "${statusMsg}" == "${expectedStatusMsg}" ]]
}

function Log::displayStatus::infoLevel { #@test
  generateLogs "Log.info.env"
  [[ "${statusMsg}" == "${expectedStatusMsg}" ]]
}

function Log::displayStatus::successLevel { #@test
  generateLogs "Log.success.env"
  [[ "${statusMsg}" == "${expectedStatusMsg}" ]]
}

function Log::displayStatus::warningLevel { #@test
  generateLogs "Log.warning.env"
  [[ "${statusMsg}" == "${expectedStatusMsg}" ]]
}

function Log::displayStatus::errorLevel { #@test
  generateLogs "Log.error.env"
  [[ -z "${statusMsg}" ]]
}

function Log::displayStatus::offLevel { #@test
  generateLogs "Log.off.env"
  [[ -z "${statusMsg}" ]]
}
