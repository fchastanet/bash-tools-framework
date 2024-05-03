#!/usr/bin/env bash

# @description Display message using error color (red) and exit immediately with error status 1
# @arg $1 message:String the message to display
# @env DISPLAY_DURATION int (default 0) if 1 display elapsed time information between 2 info logs
# @env LOG_CONTEXT String allows to contextualize the log
Log::fatal() {
  Log::computeDuration
  echo -e "${__ERROR_COLOR}FATAL   - ${LOG_CONTEXT:-}${LOG_LAST_DURATION_STR:-}${1}${__RESET_COLOR}" >&2
  Log::logFatal "$1"
  exit 1
}
