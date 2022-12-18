#!/usr/bin/env bash

Log::displayWarning() { :; }

if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_WARNING)); then
  # Display message using warning color (yellow)
  # @param {String} $1 message
  Log::displayWarning() {
    echo -e "${__WARNING_COLOR}WARN    - ${1}${__RESET_COLOR}" >&2
    Log::logWarning "$1"
  }
fi
