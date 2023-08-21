#!/usr/bin/env bash

# @description Display message using debug color (grey)
# @arg $1 message:String the message to display
Log::displayDebug() {
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_DEBUG)); then
    echo -e "${__DEBUG_COLOR}DEBUG   - ${1}${__RESET_COLOR}" >&2
  fi
  Log::logDebug "$1"
}
