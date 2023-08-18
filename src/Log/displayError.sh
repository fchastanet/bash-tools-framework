#!/usr/bin/env bash

# @description Display message using error color (red)
# @arg $1 message:String the message to display
Log::displayError() {
  echo -e "${__ERROR_COLOR}ERROR   - ${1}${__RESET_COLOR}" >&2
  Log::logError "$1"
}
