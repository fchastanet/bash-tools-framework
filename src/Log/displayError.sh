#!/usr/bin/env bash

# @description Display message using error color (red)
# @arg $1 message:String the message to display
Log::displayError() {
  if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_ERROR)); then
    Log::computeDuration
    echo -e "${__ERROR_COLOR}ERROR   - ${LOG_CONTEXT:-}${LOG_LAST_DURATION_STR:-}${1}${__RESET_COLOR}" >&2
  fi
  Log::logError "$1"
}
