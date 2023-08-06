#!/usr/bin/env bash

# Display message using info color (bg light blue/fg white)
# @param {String} $1 message
Log::displayInfo() {
  local type="${2:-INFO}"
  echo -e "${__INFO_COLOR}${type}    - ${1}${__RESET_COLOR}" >&2
  Log::logInfo "$1" "${type}"
}
