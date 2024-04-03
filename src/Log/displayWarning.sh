#!/usr/bin/env bash

# @description Display message using warning color (yellow)
# @arg $1 message:String the message to display
Log::displayWarning() {
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_WARNING)); then
    Log::computeDuration
    echo -e "${__WARNING_COLOR}WARN    - ${LOG_CONTEXT:-}${LOG_LAST_DURATION_STR:-}${1}${__RESET_COLOR}" >&2
  fi
  Log::logWarning "$1"
}
