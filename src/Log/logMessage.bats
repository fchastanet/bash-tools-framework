#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Log/_.sh
source "${srcDir}/Log/_.sh"
# shellcheck source=src/Assert/fileWritable.sh
source "${srcDir}/Assert/fileWritable.sh"
# shellcheck source=src/Assert/validPath.sh
source "${srcDir}/Assert/validPath.sh"

declare logFile
setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  logFile=""$(mktemp -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)""
}

teardown() {
  unstub_all
  rm -f "${logFile}" || true
}

function Log::logMessage::debugLevel { #@test
  stub date '* : echo "dateMocked"'
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_DEBUG}

  Log::logMessage "LEVEL" "message"
  [[ "$(cat "${logFile}")" = "dateMocked|  LEVEL|message" ]]
}

function Log::logMessage::infoLevel { #@test
  stub date '* : echo "dateMocked"'
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_INFO}

  Log::logMessage "LEVEL" "message"
  [[ "$(cat "${logFile}")" = "dateMocked|  LEVEL|message" ]]
}

function Log::logMessage::successLevel { #@test
  stub date '* : echo "dateMocked"'
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_SUCCESS}

  Log::logMessage "LEVEL" "message"
  [[ "$(cat "${logFile}")" = "dateMocked|  LEVEL|message" ]]
}

function Log::logMessage::warningLevel { #@test
  stub date '* : echo "dateMocked"'
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_WARNING}

  Log::logMessage "LEVEL" "message"
  [[ "$(cat "${logFile}")" = "dateMocked|  LEVEL|message" ]]
}

function Log::logMessage::errorLevel { #@test
  stub date '* : echo "dateMocked"'
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_ERROR}

  Log::logMessage "LEVEL" "message"
  [[ "$(cat "${logFile}")" = "dateMocked|  LEVEL|message" ]]
}

function Log::logMessage::offLevel { #@test
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_OFF}

  Log::logMessage "LEVEL" "message"
  cat "${logFile}" >&3
  [[ "$(cat "${logFile}")" = "" ]]
}

function Log::logMessage::fatalOffLevel { #@test
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_OFF}

  Log::logMessage "LEVEL" "message"
  [[ "$(cat "${logFile}")" = "" ]]
}

function Log::logMessage::fatal { #@test
  stub date '* : echo "dateMocked"'
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_DEBUG}

  Log::logMessage "FATAL" "message"
  run cat "${logFile}"
  assert_output "dateMocked|  FATAL|message"
}
