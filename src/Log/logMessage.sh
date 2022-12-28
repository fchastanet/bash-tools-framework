#!/usr/bin/env bash

# Internal: common log message
#
# **Arguments**:
# * $1 - message's level description
# * $2 - message
# **Output**:
# [date]|[levelMsg]|message
#
# **Examples**:
# <pre>
# 2020-01-19 19:20:21|ERROR  |log error
# 2020-01-19 19:20:21|SKIPPED|log skipped
# </pre>
Log::logMessage() {
  local levelMsg="$1"
  local msg="$2"
  local date

  if ((BASH_FRAMEWORK_LOG_LEVEL > __LEVEL_OFF)); then
    date="$(date '+%Y-%m-%d %H:%M:%S')"
    printf "%s|%7s|%s\n" "${date}" "${levelMsg}" "${msg}" >>"${BASH_FRAMEWORK_LOG_FILE}"
  fi
}
