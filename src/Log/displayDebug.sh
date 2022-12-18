#!/usr/bin/env bash

Log::displayDebug() { :; }

if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_DEBUG)); then
  # Display message using debug color (grey)
  # @param {String} $1 message
  Log::displayDebug() {
    echo -e "${__DEBUG_COLOR}DEBUG   - ${1}${__RESET_COLOR}" >&2
    Log::logDebug "$1"
  }
fi
