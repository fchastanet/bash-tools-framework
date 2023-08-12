#!/usr/bin/env bash

# @description Display message using success color (bg green/fg white)
# @arg $1 message:String the message to display
Log::displaySuccess() {
  echo -e "${__SUCCESS_COLOR}SUCCESS - ${1}${__RESET_COLOR}" >&2
  Log::logSuccess "$1"
}
