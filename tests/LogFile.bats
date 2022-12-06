#!/usr/bin/env bash

ROOT_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"

declare logFile
setup() {
  logFile="$(mktemp -p "${TMPDIR:-/tmp}" -t "bash.framework.XXXXXXXXXXXX")"
}

teardown() {
  rm -f "${logFile}" || true
}

assertFileLogs() {
  local logLevel=$1

  dateMocked() {
    echo "dateMocked"
  }
  alias date='dateMocked'

  echo >"${logFile}"

  expectedDebugMsg="dateMocked - DEBUG   - debug"
  Log::logDebug "debug"
  debugMsg="$(cat "${logFile}")"
  echo >"${logFile}"

  expectedInfoMsg="dateMocked - INFO    - info"
  Log::logInfo "info"
  infoMsg="$(cat "${logFile}")"
  echo >"${logFile}"

  Log::logSuccess "success"
  expectedSuccessMsg="dateMocked - SUCCESS - success"
  successMsg="$(cat "${logFile}")"
  echo >"${logFile}"

  Log::logWarning "warning"
  expectedWarningMsg="dateMocked - WARNING - warning"
  warningMsg="$(cat "${logFile}")"
  echo >"${logFile}"

  Log::logError "error"
  expectedErrorMsg="dateMocked - ERROR   - error"
  errorMsg="$(cat "${logFile}")"
  echo >"${logFile}"

  if ((logLevel == __LEVEL_OFF)); then
    [[ -z "${debugMsg}" &&
      -z "${infoMsg}" &&
      -z "${successMsg}" &&
      -z "${warningMsg}" &&
      -z "${errorMsg}" ]] &&
      return 0
  elif ((logLevel == __LEVEL_DEBUG)); then
    [[ "${debugMsg}" == "${expectedDebugMsg}" &&
      "${infoMsg}" == "${expectedInfoMsg}" &&
      "${successMsg}" == "${expectedSuccessMsg}" &&
      "${warningMsg}" == "${expectedWarningMsg}" &&
      "${errorMsg}" == "${expectedErrorMsg}" ]] &&
      return 0
  elif ((logLevel == __LEVEL_INFO)); then
    [[ -z "${debugMsg}" &&
      "${infoMsg}" == "${expectedInfoMsg}" &&
      "${successMsg}" == "${expectedSuccessMsg}" &&
      "${warningMsg}" == "${expectedWarningMsg}" &&
      "${errorMsg}" == "${expectedErrorMsg}" ]] &&
      return 0
  elif ((logLevel == __LEVEL_SUCCESS)); then
    [[ -z "${debugMsg}" &&
      "${infoMsg}" == "${expectedInfoMsg}" &&
      "${successMsg}" == "${expectedSuccessMsg}" &&
      "${warningMsg}" == "${expectedWarningMsg}" &&
      "${errorMsg}" == "${expectedErrorMsg}" ]] &&
      return 0
  elif ((logLevel == __LEVEL_WARNING)); then
    [[ -z "${debugMsg}" &&
      -z "${infoMsg}" &&
      -z "${successMsg}" &&
      "${warningMsg}" == "${expectedWarningMsg}" &&
      "${errorMsg}" == "${expectedErrorMsg}" ]] &&
      return 0
  elif ((logLevel == __LEVEL_ERROR)); then
    [[ -z "${debugMsg}" &&
      -z "${infoMsg}" &&
      -z "${successMsg}" &&
      -z "${warningMsg}" &&
      "${errorMsg}" == "${expectedErrorMsg}" ]] &&
      return 0
  fi
  return 1
}

function log_file_not_specified { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.debug.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" == "${__LEVEL_OFF}" ]]
}

function log_log_file_not_writable { #@test
  chmod 400 "${logFile}"
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.debug.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  [[ "${BASH_FRAMEWORK_LOG_LEVEL}" == "${__LEVEL_OFF}" ]]
}

function log_logDebug_activated_with_envfile { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.debug.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1

  run assertFileLogs "${__LEVEL_DEBUG}"
  # shellcheck disable=SC2154
  [[ "${status}" == "0" ]]
}

function log_logDebug_activated_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_DEBUG} \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertFileLogs "${__LEVEL_DEBUG}"
  [[ "${status}" == "0" ]]
}

function log_logInfo_activated_with_envfile { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.info.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertFileLogs "${__LEVEL_INFO}"
  [[ "${status}" == "0" ]]
}

function log_logInfo_activated_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_INFO} \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertFileLogs "${__LEVEL_INFO}"
  [[ "${status}" == "0" ]]
}

function log_logSuccess_activated_with_envfile { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.success.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertFileLogs "${__LEVEL_SUCCESS}"
  [[ "${status}" == "0" ]]
}

function log_logSuccess_activated_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_SUCCESS} \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertFileLogs "${__LEVEL_SUCCESS}"
  [[ "${status}" == "0" ]]
}

function log_logWarning_activated_with_envfile { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.warning.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertFileLogs "${__LEVEL_WARNING}"
  [[ "${status}" == "0" ]]
}

function log_logWarning_activated_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_WARNING} \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertFileLogs "${__LEVEL_WARNING}"
  [[ "${status}" == "0" ]]
}

function log_logError_activated_with_envfile { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.error.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertFileLogs "${__LEVEL_ERROR}"
  [[ "${status}" == "0" ]]
}

function log_logError_activated_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_ERROR} \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertFileLogs "${__LEVEL_ERROR}"
  [[ "${status}" == "0" ]]
}

function log_off_with_env_file { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_ENV_FILEPATH="${BATS_TEST_DIRNAME}/data/Log.off.env" \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertFileLogs "${__LEVEL_OFF}"
  [[ "${status}" == "0" ]]
}

function log_off_with_env_var { #@test
  # shellcheck source=/src/Framework/loadEnv.sh
  BASH_FRAMEWORK_LOG_FILE="${logFile}" \
    BASH_FRAMEWORK_INITIALIZED=0 \
    BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_OFF} \
    source "${ROOT_DIR}/src/Framework/loadEnv.sh" || exit 1
  run assertFileLogs "${__LEVEL_OFF}"
  [[ "${status}" == "0" ]]
}
