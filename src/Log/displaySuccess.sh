#!/usr/bin/env bash

Log::displaySuccess() { :; }

if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_INFO)); then
  # Display message using success color (bg green/fg white)
  # @param {String} $1 message
  Log::displaySuccess() {
    echo -e "${__SUCCESS_COLOR}SUCCESS - ${1}${__RESET_COLOR}" >&2
    Log::logSuccess "$1"
  }
fi
