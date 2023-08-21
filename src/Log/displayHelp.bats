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

  helpMsg=$(Log::displayHelp "help" 2>&1)
  expectedHelpMsg="$(echo -e "${__HELP_COLOR}HELP    - help${__RESET_COLOR}")"
}

function Log::displayHelp::debugLevel { #@test
  generateLogs "Log.debug.env"
  [[ "${helpMsg}" == "${expectedHelpMsg}" ]]
}

function Log::displayHelp::infoLevel { #@test
  generateLogs "Log.info.env"
  [[ "${helpMsg}" == "${expectedHelpMsg}" ]]
}

function Log::displayHelp::successLevel { #@test
  generateLogs "Log.success.env"
  [[ "${helpMsg}" == "${expectedHelpMsg}" ]]
}

function Log::displayHelp::warningLevel { #@test
  generateLogs "Log.warning.env"
  [[ -z "${helpMsg}" ]]
}

function Log::displayHelp::errorLevel { #@test
  generateLogs "Log.error.env"
  [[ -z "${helpMsg}" ]]
}

function Log::displayHelp::offLevel { #@test
  generateLogs "Log.off.env"
  [[ -z "${helpMsg}" ]]
}
