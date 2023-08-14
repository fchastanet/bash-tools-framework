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
Log::logMessage() {
  local levelMsg="$1"
  local msg="$2"
  local date

  if [[ -z "${BASH_FRAMEWORK_LOG_FILE}" ]]; then
    return 0
  fi
  if ((BASH_FRAMEWORK_LOG_LEVEL > __LEVEL_OFF)) || [[ "${levelMsg}" = "FATAL" ]]; then
    mkdir -p "$(dirname "${BASH_FRAMEWORK_LOG_FILE}")" || true
    if Assert::fileWritable "${BASH_FRAMEWORK_LOG_FILE}"; then
      date="$(date '+%Y-%m-%d %H:%M:%S')"
      touch "${BASH_FRAMEWORK_LOG_FILE}"
      printf "%s|%7s|%s\n" "${date}" "${levelMsg}" "${msg}" >>"${BASH_FRAMEWORK_LOG_FILE}"
    else
      echo -e "${__ERROR_COLOR}ERROR   - File ${BASH_FRAMEWORK_LOG_FILE} is not writable${__RESET_COLOR}" >&2
    fi
  fi
}
