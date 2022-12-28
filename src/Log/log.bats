#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

declare logFile
setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
  logFile="${BATS_TMP_DIR}/log"

  unset HOME
  unset ROOT_DIR
  export BASH_FRAMEWORK_INITIALIZED=0
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=0
}

teardown() {
  unstub_all
  rm -Rf "${BATS_TMP_DIR}" || true
}

generateLogs() {
  Log::logDebug "debug"
  Log::logInfo "info"
  Log::logSuccess "success"
  Log::logSkipped "skipped"
  Log::logHelp "help"
  Log::logWarning "warning"
  Log::logError "error"
  (
    trap '' EXIT
    Log::fatal 'fatal' 2>/dev/null
  ) || true
}

function Log::log::debugLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.debug.env"
  Env::load
  stub date \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"'

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  run cat "${logFile}"

  assert_line --index 0 "dateMocked|   INFO|Logging to file ${logFile}"
  assert_line --index 1 "dateMocked|  DEBUG|debug"
  assert_line --index 2 "dateMocked|   INFO|info"
  assert_line --index 3 "dateMocked|SUCCESS|success"
  assert_line --index 4 "dateMocked|SKIPPED|skipped"
  assert_line --index 5 "dateMocked|   HELP|help"
  assert_line --index 6 "dateMocked|WARNING|warning"
  assert_line --index 7 "dateMocked|  ERROR|error"
  assert_line --index 8 "dateMocked|  FATAL|fatal"
}

function Log::log::infoLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.info.env"
  Env::load
  stub date \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"'

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  run cat "${logFile}"

  assert_line --index 0 "dateMocked|   INFO|Logging to file ${logFile}"
  assert_line --index 1 "dateMocked|   INFO|info"
  assert_line --index 2 "dateMocked|SUCCESS|success"
  assert_line --index 3 "dateMocked|SKIPPED|skipped"
  assert_line --index 4 "dateMocked|   HELP|help"
  assert_line --index 5 "dateMocked|WARNING|warning"
  assert_line --index 6 "dateMocked|  ERROR|error"
  assert_line --index 7 "dateMocked|  FATAL|fatal"
}

function Log::log::successLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.success.env"
  Env::load
  stub date \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"'

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  run cat "${logFile}"

  assert_line --index 0 "dateMocked|   INFO|Logging to file ${logFile}"
  assert_line --index 1 "dateMocked|   INFO|info"
  assert_line --index 2 "dateMocked|SUCCESS|success"
  assert_line --index 3 "dateMocked|SKIPPED|skipped"
  assert_line --index 4 "dateMocked|   HELP|help"
  assert_line --index 5 "dateMocked|WARNING|warning"
  assert_line --index 6 "dateMocked|  ERROR|error"
  assert_line --index 7 "dateMocked|  FATAL|fatal"
}

function Log::log::warningLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.warning.env"
  Env::load
  stub date \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"'

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  run cat "${logFile}"

  assert_line --index 0 "dateMocked|WARNING|warning"
  assert_line --index 1 "dateMocked|  ERROR|error"
  assert_line --index 2 "dateMocked|  FATAL|fatal"
}

function Log::log::errorLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.error.env"
  Env::load
  stub date \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"'

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  run cat "${logFile}"

  assert_line --index 0 "dateMocked|  ERROR|error"
  assert_line --index 1 "dateMocked|  FATAL|fatal"
}

function Log::log::offLevel { #@test
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/Log.off.env"
  Env::load

  # shellcheck source=src/Log/ZZZ.sh
  source "${srcDir}/Log/ZZZ.sh"

  generateLogs
  [[ "$(cat "${logFile}")" = "" ]]
}
