#!/usr/bin/env bash

# @description Display message using info color (bg light blue/fg white)
# @arg $1 message:String the message to display
Log::displayHelp() {
  local type="${2:-HELP}"
  echo -e "${__HELP_COLOR}${type}    - ${1}${__RESET_COLOR}" >&2
  Log::logHelp "$1" "${type}"
}
