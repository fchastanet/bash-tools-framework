#!/usr/bin/env bash

# @description Display message using debug color (grey)
# @arg $1 message:String the message to display
Log::displayDebug() {
  echo -e "${__DEBUG_COLOR}DEBUG   - ${1}${__RESET_COLOR}" >&2
  Log::logDebug "$1"
}
