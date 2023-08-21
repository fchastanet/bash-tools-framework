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

generateLogs() {
  local logEnvFile="$1"
  export BASH_FRAMEWORK_ENV_FILES=("${BATS_TEST_DIRNAME}/testsData/${logEnvFile}")

  Env::requireLoad
  Log::requireLoad

  fatalMsg=$(
    trap '' EXIT
    Log::fatal 'fatal' 2>&1
  ) || true
  expectedFatalMsg="$(echo -e "${__ERROR_COLOR}FATAL   - fatal${__RESET_COLOR}")"
}

function Log::fatal::debugLevel { #@test
  generateLogs "Log.debug.env"
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}

function Log::fatal::infoLevel { #@test
  generateLogs "Log.info.env"
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}

function Log::fatal::successLevel { #@test
  generateLogs "Log.success.env"
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}

function Log::fatal::warningLevel { #@test
  generateLogs "Log.warning.env"
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}

function Log::fatal::errorLevel { #@test
  generateLogs "Log.error.env"
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}

function Log::fatal::offLevel { #@test
  generateLogs "Log.off.env"
  [[ "${fatalMsg}" == "${expectedFatalMsg}" ]]
}
