#!/usr/bin/env bash

# Display message using warning color (yellow)
# @param {String} $1 message
Log::displayWarning() {
  echo -e "${__WARNING_COLOR}WARN    - ${1}${__RESET_COLOR}" >&2
}
