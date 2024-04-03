#!/usr/bin/env bash

# @description Display message using info color (blue) but warning level
# @arg $1 message:String the message to display
Log::displayStatus() {
  local type="${2:-STATUS}"
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_WARNING)); then
    Log::computeDuration
    echo -e "${__INFO_COLOR}${type}  - ${LOG_CONTEXT:-}${LOG_LAST_DURATION_STR:-}${1}${__RESET_COLOR}" >&2
  fi
  Log::logStatus "$1" "${type}"
}
