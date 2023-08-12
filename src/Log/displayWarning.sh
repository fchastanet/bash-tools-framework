#!/usr/bin/env bash

# @description Display message using warning color (yellow)
# @arg $1 message:String the message to display
Log::displayWarning() {
  echo -e "${__WARNING_COLOR}WARN    - ${1}${__RESET_COLOR}" >&2
  Log::logWarning "$1"
}
