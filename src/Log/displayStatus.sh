#!/usr/bin/env bash

# @description Display message using info color (blue) but warning level
# @arg $1 message:String the message to display
Log::displayStatus() {
  local type="${2:-STATUS}"
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_WARNING)); then
    echo -e "${__INFO_COLOR}${type}  - ${1}${__RESET_COLOR}" >&2
  fi
  Log::logStatus "$1" "${type}"
}
