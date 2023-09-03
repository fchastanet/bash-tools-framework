#!/usr/bin/env bash

# @description default env file with all default values
# @stdout the default env filepath
Env::createDefaultEnvFile() {
  local envFile
  envFile="$(Framework::createTempFile "createDefaultEnvFileEnvFile")" || return 2

  (
    echo "BASH_FRAMEWORK_THEME=${BASH_FRAMEWORK_THEME:-default}"
    echo "BASH_FRAMEWORK_LOG_LEVEL=${BASH_FRAMEWORK_LOG_LEVEL:-0}"
    echo "BASH_FRAMEWORK_DISPLAY_LEVEL=${BASH_FRAMEWORK_DISPLAY_LEVEL:-${__LEVEL_WARNING}}"
    # shellcheck disable=SC2016
    echo 'BASH_FRAMEWORK_LOG_FILE="${BASH_FRAMEWORK_LOG_FILE:-"${FRAMEWORK_ROOT_DIR}/logs/${SCRIPT_NAME}.log"}"'
    echo "BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION:-5}"
  ) >"${envFile}"
  echo "${envFile}"
}
