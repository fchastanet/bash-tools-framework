#!/usr/bin/env bash

# @description Display message using warning color (yellow)
# @arg $1 message:String the message to display
Log::displayWarning() {
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_WARNING)); then
    echo -e "${__WARNING_COLOR}WARN    - ${1}${__RESET_COLOR}" >&2
  fi
  Log::logWarning "$1"
}
