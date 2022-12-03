#!/usr/bin/env bash

# Display message using skip color (yellow)
# @param {String} $1 message
Log::displaySkipped() {
  echo -e "${__SKIPPED_COLOR}SKIPPED - ${1}${__RESET_COLOR}"
}
