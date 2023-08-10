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
  export TMPDIR="${BATS_TEST_TMPDIR}"
  logFile=""$(mktemp -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)""

  unset HOME
  unset FRAMEWORK_ROOT_DIR
  export BASH_FRAMEWORK_INITIALIZED=0
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=0
}

teardown() {
  unstub_all
  rm -f "${logFile}" || true
}

generateLogs() {
  local envFile="$1"
  export BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/testsData/${envFile}"
  Env::load
  Log::load

  Log::logSkipped "skipped"
}

function Log::logSkipped::debugLevel { #@test
  stub date \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"'
  generateLogs "Log.debug.env"
  run cat "${logFile}"

  assert_lines_count 2
  assert_line --index 0 "dateMocked|   INFO|Logging to file ${logFile}"
  assert_line --index 1 "dateMocked|SKIPPED|skipped"
}

function Log::logSkipped::infoLevel { #@test
  stub date \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"'
  generateLogs "Log.info.env"
  run cat "${logFile}"

  assert_lines_count 2
  assert_line --index 0 "dateMocked|   INFO|Logging to file ${logFile}"
  assert_line --index 1 "dateMocked|SKIPPED|skipped"
}

function Log::logSkipped::successLevel { #@test
  stub date \
    '* : echo "dateMocked"' \
    '* : echo "dateMocked"'
  generateLogs "Log.success.env"
  run cat "${logFile}"

  assert_lines_count 2
  assert_line --index 0 "dateMocked|   INFO|Logging to file ${logFile}"
  assert_line --index 1 "dateMocked|SKIPPED|skipped"
}

function Log::logSkipped::warningLevel { #@test
  stub date \
    '* : echo "dateMocked"'
  generateLogs "Log.warning.env"
  run cat "${logFile}"

  assert_output ""
}

function Log::logSkipped::errorLevel { #@test
  stub date \
    '* : echo "dateMocked"'
  generateLogs "Log.error.env"
  run cat "${logFile}"

  assert_output ""
}

function Log::logSkipped::offLevel { #@test
  generateLogs "Log.off.env"
  run cat "${logFile}"

  assert_output ""
}
