#!/usr/bin/env bash

# @description log message to file
# @arg $1 message:String the message to display
Log::logSkipped() {
  if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_INFO)); then
    Log::logMessage "${2:-SKIPPED}" "$1"
  fi
}
