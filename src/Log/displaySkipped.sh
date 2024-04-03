#!/usr/bin/env bash

# @description Display message using skip color (yellow)
# @arg $1 message:String the message to display
Log::displaySkipped() {
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_INFO)); then
    Log::computeDuration
    echo -e "${__SKIPPED_COLOR}SKIPPED - ${LOG_CONTEXT:-}${LOG_LAST_DURATION_STR:-}${1}${__RESET_COLOR}" >&2
  fi
  Log::logSkipped "$1"
}
