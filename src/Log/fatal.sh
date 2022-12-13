#!/usr/bin/env bash

# Display message using error color (red) and exit immediately with error status 1
# @param {String} $1 message
Log::fatal() {
  echo -e "${__ERROR_COLOR}FATAL   - ${1}${__RESET_COLOR}" >&2
  exit 1
}
