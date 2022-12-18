#!/usr/bin/env bash

# Public: log level off
export __LEVEL_OFF=0
# Public: log level error
export __LEVEL_ERROR=1
# Public: log level warning
export __LEVEL_WARNING=2
# Public: log level info
export __LEVEL_INFO=3
# Public: log level success
export __LEVEL_SUCCESS=3
# Public: log level debug
export __LEVEL_DEBUG=4

export __LEVEL_OFF
export __LEVEL_ERROR
export __LEVEL_WARNING
export __LEVEL_INFO
export __LEVEL_SUCCESS
export __LEVEL_DEBUG

if [[ -t 1 || -t 2 ]]; then
  # check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
  readonly __ERROR_COLOR='\e[31m'      # Red
  readonly __INFO_COLOR='\e[44m'       # white on lightBlue
  readonly __SUCCESS_COLOR='\e[32m'    # Green
  readonly __WARNING_COLOR='\e[33m'    # Yellow
  readonly __TEST_COLOR='\e[100m'      # Light magenta
  readonly __TEST_ERROR_COLOR='\e[41m' # white on red
  readonly __SKIPPED_COLOR='\e[33m'    # Yellow
  readonly __DEBUG_COLOR='\e[37m'      # Grey
  # Internal: reset color
  readonly __RESET_COLOR='\e[0m' # Reset Color
  # shellcheck disable=SC2155,SC2034
  readonly __HELP_EXAMPLE="$(echo -e "\e[1;30m")"
  # shellcheck disable=SC2155,SC2034
  readonly __HELP_TITLE="$(echo -e "\e[1;37m")"
  # shellcheck disable=SC2155,SC2034
  readonly __HELP_NORMAL="$(echo -e "\033[0m")"
else
  # check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
  readonly __ERROR_COLOR=''
  readonly __INFO_COLOR=''
  readonly __SUCCESS_COLOR=''
  readonly __WARNING_COLOR=''
  readonly __SKIPPED_COLOR=''
  readonly __TEST_COLOR=''
  readonly __TEST_ERROR_COLOR=''
  readonly __DEBUG_COLOR=''
  # Internal: reset color
  readonly __RESET_COLOR=''
  readonly __HELP_EXAMPLE=''
  readonly __HELP_TITLE=''
  readonly __HELP_NORMAL=''
fi
export __ERROR_COLOR
export __INFO_COLOR
export __SUCCESS_COLOR
export __WARNING_COLOR
export __SKIPPED_COLOR
export __TEST_COLOR
export __TEST_ERROR_COLOR
export __SKIPPED_COLOR
export __DEBUG_COLOR
export __RESET_COLOR
export __HELP_EXAMPLE
export __HELP_TITLE
export __HELP_NORMAL

Env::load

if [[ -z "${BASH_FRAMEWORK_LOG_FILE}" ]]; then
  BASH_FRAMEWORK_LOG_LEVEL=${__LEVEL_OFF}
  export BASH_FRAMEWORK_LOG_LEVEL
elif [[ ! -f "${BASH_FRAMEWORK_LOG_FILE}" ]]; then
  if ! mkdir -p "$(dirname "${BASH_FRAMEWORK_LOG_FILE}")" 2>/dev/null; then
    Log::fatal "Log dir cannot be created $(dirname "${BASH_FRAMEWORK_LOG_FILE}")"
  fi
  if ! touch --no-create "${BASH_FRAMEWORK_LOG_FILE}" 2>/dev/null; then
    Log::fatal "Log file '${BASH_FRAMEWORK_LOG_FILE}' cannot be created"
  fi
else
  if ((BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION > 0)); then
    Log::rotate "${BASH_FRAMEWORK_LOG_FILE}" "${BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION}"
  fi
fi
