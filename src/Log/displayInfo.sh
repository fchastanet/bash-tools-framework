#!/usr/bin/env bash

Log::displayInfo() { :; }

if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_INFO)); then
  # Display message using info color (bg light blue/fg white)
  # @param {String} $1 message
  Log::displayInfo() {
    echo -e "${__INFO_COLOR}INFO    - ${1}${__RESET_COLOR}" >&2
    Log::logInfo "$1"
  }
fi
