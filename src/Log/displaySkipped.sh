#!/usr/bin/env bash

# @description Display message using skip color (yellow)
# @arg $1 message:String the message to display
Log::displaySkipped() {
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_INFO)); then
    echo -e "${__SKIPPED_COLOR}SKIPPED - ${1}${__RESET_COLOR}" >&2
  fi
  Log::logSkipped "$1"
}
