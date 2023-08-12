#!/usr/bin/env bash

# @description Display message using error color (red) and exit immediately with error status 1
# @arg $1 message:String the message to display
Log::fatal() {
  echo -e "${__ERROR_COLOR}FATAL   - ${1}${__RESET_COLOR}" >&2
  Log::logFatal "$1"
  exit 1
}
