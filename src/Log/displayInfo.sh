#!/usr/bin/env bash

# Display message using info color (bg light blue/fg white)
# @param {String} $1 message
Log::displayInfo() {
  echo -e "${__INFO_COLOR}INFO    - ${1}${__RESET_COLOR}"
}
