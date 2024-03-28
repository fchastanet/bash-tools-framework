#!/usr/bin/env bash

# @description Display message using debug color (grey)
# @arg $1 message:String the message to display
Log::displayDebug() {
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_DEBUG)); then
    Log::computeDuration
    echo -e "${__DEBUG_COLOR}DEBUG   - ${LOG_LAST_DURATION_STR}${1}${__RESET_COLOR}" >&2
  fi
  Log::logDebug "$1"
}
