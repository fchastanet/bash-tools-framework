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

  unset HOME
  unset ROOT_DIR
  export BASH_FRAMEWORK_INITIALIZED=0
  export BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=0
}

generateLogs() {
  local logEnvFile="$1"
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/${logEnvFile}"

  Env::load

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  debugMsg=$(Log::displayDebug "debug" 2>&1)
  expectedDebugMsg="$(echo -e "${__DEBUG_COLOR}DEBUG   - debug${__RESET_COLOR}")"
}

function Log::displayDebug::debugLevel { #@test
  generateLogs "Log.debug.env"
  [[ "${debugMsg}" == "${expectedDebugMsg}" ]]
}

function Log::displayDebug::infoLevel { #@test
  generateLogs "Log.info.env"
  [[ -z "${debugMsg}" ]]
}

function Log::displayDebug::successLevel { #@test
  generateLogs "Log.success.env"
  [[ -z "${debugMsg}" ]]
}

function Log::displayDebug::warningLevel { #@test
  generateLogs "Log.warning.env"
  [[ -z "${debugMsg}" ]]
}

function Log::displayDebug::errorLevel { #@test
  generateLogs "Log.error.env"
  [[ -z "${debugMsg}" ]]
}

function Log::displayDebug::offLevel { #@test
  generateLogs "Log.off.env"
  [[ -z "${debugMsg}" ]]
}
