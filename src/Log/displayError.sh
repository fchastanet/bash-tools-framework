#!/usr/bin/env bash

# Display message using error color (red)
# @param {String} $1 message
Log::displayError() {
  echo -e "${__ERROR_COLOR}ERROR   - ${1}${__RESET_COLOR}"
}
