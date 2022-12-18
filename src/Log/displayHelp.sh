#!/usr/bin/env bash

Log::displayHelp() { :; }

if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_INFO)); then
  # Display message using info color (bg light blue/fg white)
  # @param {String} $1 message
  Log::displayHelp() {
    echo -e "${__INFO_COLOR}HELP    - ${1}${__RESET_COLOR}" >&2
    Log::logHelp "$1"
  }
fi
