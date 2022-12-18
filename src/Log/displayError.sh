#!/usr/bin/env bash

Log::displayError() { :; }

if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_ERROR)); then
  # Display message using error color (red)
  # @param {String} $1 message
  Log::displayError() {
    echo -e "${__ERROR_COLOR}ERROR   - ${1}${__RESET_COLOR}" >&2
    Log::logError "$1"
  }
fi
