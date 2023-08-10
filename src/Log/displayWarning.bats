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
  export BASH_FRAMEWORK_INITIALIZED=0
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=0
}

teardown() {
  rm -f "${logFile}" || true
}

generateLogs() {
  local logEnvFile="$1"
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/${logEnvFile}"

  Env::load
  Log::load

  warningMsg=$(Log::displayWarning "warning" 2>&1)
  expectedWarningMsg="$(echo -e "${__WARNING_COLOR}WARN    - warning${__RESET_COLOR}")"
}

function Log::displayWarning::debugLevel { #@test
  generateLogs "Log.debug.env"
  [[ "${warningMsg}" == "${expectedWarningMsg}" ]]
}

function Log::displayWarning::infoLevel { #@test
  generateLogs "Log.info.env"
  [[ "${warningMsg}" == "${expectedWarningMsg}" ]]
}

function Log::displayWarning::successLevel { #@test
  generateLogs "Log.success.env"
  [[ "${warningMsg}" == "${expectedWarningMsg}" ]]
}

function Log::displayWarning::warningLevel { #@test
  generateLogs "Log.warning.env"
  [[ "${warningMsg}" == "${expectedWarningMsg}" ]]
}

function Log::displayWarning::errorLevel { #@test
  generateLogs "Log.error.env"
  [[ -z "${warningMsg}" ]]
}

function Log::displayWarning::offLevel { #@test
  generateLogs "Log.off.env"
  [[ -z "${warningMsg}" ]]
}
