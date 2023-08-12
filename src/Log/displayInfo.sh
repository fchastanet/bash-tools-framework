#!/usr/bin/env bash

# @description Display message using info color (bg light blue/fg white)
# @arg $1 message:String the message to display
Log::displayInfo() {
  local type="${2:-INFO}"
  echo -e "${__INFO_COLOR}${type}    - ${1}${__RESET_COLOR}" >&2
  Log::logInfo "$1" "${type}"
}
