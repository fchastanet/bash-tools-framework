#!/usr/bin/env bash

# @description Display message using success color (bg green/fg white)
# @arg $1 message:String the message to display
Log::displaySuccess() {
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_INFO)); then
    echo -e "${__SUCCESS_COLOR}SUCCESS - ${1}${__RESET_COLOR}" >&2
  fi
  Log::logSuccess "$1"
}
