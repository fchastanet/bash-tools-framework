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
  export TMPDIR="${BATS_RUN_TMPDIR}"

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

  successMsg=$(Log::displaySuccess "success" 2>&1)
  expectedSuccessMsg="$(echo -e "${__SUCCESS_COLOR}SUCCESS - success${__RESET_COLOR}")"
}

function Log::displaySuccess::debugLevel { #@test
  generateLogs "Log.debug.env"
  [[ "${successMsg}" == "${expectedSuccessMsg}" ]]
}

function Log::displaySuccess::infoLevel { #@test
  generateLogs "Log.info.env"
  [[ "${successMsg}" == "${expectedSuccessMsg}" ]]
}

function Log::displaySuccess::successLevel { #@test
  generateLogs "Log.success.env"
  [[ "${successMsg}" == "${expectedSuccessMsg}" ]]
}

function Log::displaySuccess::warningLevel { #@test
  generateLogs "Log.warning.env"
  [[ -z "${successMsg}" ]]
}

function Log::displaySuccess::errorLevel { #@test
  generateLogs "Log.error.env"
  [[ -z "${successMsg}" ]]
}

function Log::displaySuccess::offLevel { #@test
  generateLogs "Log.off.env"
  [[ -z "${successMsg}" ]]
}
