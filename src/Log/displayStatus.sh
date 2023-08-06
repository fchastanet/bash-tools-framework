#!/usr/bin/env bash

# Display message using info color (blue) but warning level
# @param {String} $1 message
Log::displayStatus() {
  local type="${2:-STATUS}"
  echo -e "${__INFO_COLOR}${type}  - ${1}${__RESET_COLOR}" >&2
  Log::logStatus "$1" "${type}"
}
