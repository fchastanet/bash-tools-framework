#!/usr/bin/env bash

Log::displaySkipped() { :; }

if ((BASH_FRAMEWORK_DISPLAY_LEVEL >= __LEVEL_WARNING)); then
  # Display message using skip color (yellow)
  # @param {String} $1 message
  Log::displaySkipped() {
    echo -e "${__SKIPPED_COLOR}SKIPPED - ${1}${__RESET_COLOR}" >&2
    Log::logSkipped "$1"
  }
fi
