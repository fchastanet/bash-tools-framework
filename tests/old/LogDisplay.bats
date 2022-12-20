#!/usr/bin/env bash
declare ROOT_DIR

ROOT_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"

declare logFile
setup() {
  export HOME="/tmp/home"
  mkdir -p /tmp/home
  logFile="$(mktemp -p "${TMPDIR:-/tmp}" -t "bash.framework.XXXXXXXXXXXX")"
}

teardown() {
  rm -f "${logFile}" || true
  rm -Rf /tmp/home || true
}

assertDisplayLogs() {
  local displayLevel=$1

  local debugMsg expectedDebugMsg infoMsg expectedInfoMsg
  local successMsg expectedSuccessMsg warningMsg expectedWarningMsg
  local errorMsg expectedErrorMsg
  debugMsg=$(Log::displayDebug "debug" 2>&1)
  expectedDebugMsg="$(echo -e "${__DEBUG_COLOR}DEBUG - debug${__RESET_COLOR}")"
  infoMsg=$(Log::displayInfo "info" 2>&1)
  expectedInfoMsg="$(echo -e "${__INFO_COLOR}INFO  - info${__RESET_COLOR}")"
  successMsg=$(Log::displaySuccess "success" 2>&1)
  expectedSuccessMsg="$(echo -e "${__SUCCESS_COLOR}success${__RESET_COLOR}")"
  warningMsg=$(Log::displayWarning "warning" 2>&1)
  expectedWarningMsg="$(echo -e "${__WARNING_COLOR}WARN  - warning${__RESET_COLOR}")"
  errorMsg=$(Log::displayError "error" 2>&1)
  expectedErrorMsg="$(echo -e "${__ERROR_COLOR}ERROR - error${__RESET_COLOR}")"

  if ((displayLevel == __LEVEL_OFF)); then
    [[ -z "${debugMsg}" &&
      -z "${infoMsg}" &&
      -z "${successMsg}" &&
      -z "${warningMsg}" &&
      -z "${errorMsg}" ]] &&
      return 0
  elif ((displayLevel == __LEVEL_DEBUG)); then
    [[ "${debugMsg}" == "${expectedDebugMsg}" &&
      "${infoMsg}" == "${expectedInfoMsg}" &&
      "${successMsg}" == "${expectedSuccessMsg}" &&
      "${warningMsg}" == "${expectedWarningMsg}" &&
      "${errorMsg}" == "${expectedErrorMsg}" ]] &&
      return 0
  elif ((displayLevel == __LEVEL_INFO)); then
    [[ -z "${debugMsg}" &&
      "${infoMsg}" == "${expectedInfoMsg}" &&
      "${successMsg}" == "${expectedSuccessMsg}" &&
      "${warningMsg}" == "${expectedWarningMsg}" &&
      "${errorMsg}" == "${expectedErrorMsg}" ]] &&
      return 0
  elif ((displayLevel == __LEVEL_SUCCESS)); then
    [[ -z "${debugMsg}" &&
      "${infoMsg}" == "${expectedInfoMsg}" &&
      "${successMsg}" == "${expectedSuccessMsg}" &&
      "${warningMsg}" == "${expectedWarningMsg}" &&
      "${errorMsg}" == "${expectedErrorMsg}" ]] &&
      return 0
  elif ((displayLevel == __LEVEL_WARNING)); then
    [[ -z "${debugMsg}" &&
      -z "${infoMsg}" &&
      -z "${successMsg}" &&
      "${warningMsg}" == "${expectedWarningMsg}" &&
      "${errorMsg}" == "${expectedErrorMsg}" ]] &&
      return 0
  elif ((displayLevel == __LEVEL_ERROR)); then
    [[ -z "${debugMsg}" &&
      -z "${infoMsg}" &&
      -z "${successMsg}" &&
      -z "${warningMsg}" &&
      "${errorMsg}" == "${expectedErrorMsg}" ]] &&
      return 0
  fi
  return 1
}

function log_displayDebug_activated_with_envFile { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.debug.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertDisplayLogs "${__LEVEL_DEBUG}"
  # shellcheck disable=SC2154
  [[ "${status}" == "0" ]]
}

function log_displayDebug_activated_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL="${__LEVEL_DEBUG}" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertDisplayLogs "${__LEVEL_DEBUG}"
  [[ "${status}" == "0" ]]
}

function log_displayInfo_activated_with_envFile { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.info.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  assertDisplayLogs "${__LEVEL_INFO}"
}

function log_displayInfo_activated_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL="${__LEVEL_INFO}" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  assertDisplayLogs "${__LEVEL_INFO}"
}

function log_displaySuccess_activated_with_envFile { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.success.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  assertDisplayLogs "${__LEVEL_SUCCESS}"
}

function log_displaySuccess_activated_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL="${__LEVEL_SUCCESS}" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  assertDisplayLogs "${__LEVEL_SUCCESS}"
}

function log_displayWarning_activated_with_envFile { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.warning.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  assertDisplayLogs "${__LEVEL_WARNING}"
}

function log_displayWarning_activated_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_WARNING} \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  assertDisplayLogs "${__LEVEL_WARNING}"
}

function log_displayError_activated_with_envFile { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.error.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  assertDisplayLogs "${__LEVEL_ERROR}"
}

function log_displayError_activated_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_ERROR} \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  assertDisplayLogs "${__LEVEL_ERROR}"
}

function log_fatal { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_ERROR} \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run Log::fatal 'fatal msg'
  # shellcheck disable=SC2154
  [[ "${status}" -eq 1 ]]
  # shellcheck disable=SC2154
  [[ "$(echo -e "${__FATAL_COLOR}FATAL - fatal msg${__RESET_COLOR}")" = "${output}" ]]
}

function display_off_with_env_file { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.off.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  assertDisplayLogs "${__LEVEL_OFF}"
}

function display_off_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_OFF} \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  assertDisplayLogs "${__LEVEL_OFF}"
}
