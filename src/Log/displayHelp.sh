#!/usr/bin/env bash

# Display message using info color (bg light blue/fg white)
# @param {String} $1 message
Log::displayHelp() {
  echo -e "${__HELP_COLOR}HELP    - ${1}${__RESET_COLOR}" >&2
  Log::logHelp "$1"
}
