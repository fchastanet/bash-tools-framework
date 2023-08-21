#!/usr/bin/env bash

# @description Internal: common log message
# @example text
#   [date]|[levelMsg]|message
#
# @example text
#   2020-01-19 19:20:21|ERROR  |log error
#   2020-01-19 19:20:21|SKIPPED|log skipped
#
# @arg $1 levelMsg:String message's level description (eg: STATUS, ERROR, ...)
# @arg $2 msg:String the message to display
# @env BASH_FRAMEWORK_LOG_FILE String log file to use, do nothing if empty
# @env BASH_FRAMEWORK_LOG_LEVEL int log level log only if > OFF or fatal messages
# @stderr diagnostics information is displayed
# @require Env::requireLoad
# @require Log::requireLoad
Log::logMessage() {
  local levelMsg="$1"
  local msg="$2"
  local date

  if [[ -n "${BASH_FRAMEWORK_LOG_FILE}" ]] && ((BASH_FRAMEWORK_LOG_LEVEL > __LEVEL_OFF)); then
    date="$(date '+%Y-%m-%d %H:%M:%S')"
    touch "${BASH_FRAMEWORK_LOG_FILE}"
    printf "%s|%7s|%s\n" "${date}" "${levelMsg}" "${msg}" >>"${BASH_FRAMEWORK_LOG_FILE}"
  fi
}
