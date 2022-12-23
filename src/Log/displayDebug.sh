#!/usr/bin/env bash

# Display message using debug color (grey)
# @param {String} $1 message
Log::displayDebug() {
  echo -e "${__DEBUG_COLOR}DEBUG   - ${1}${__RESET_COLOR}" >&2
  Log::logDebug "$1"
}
