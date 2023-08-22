#!/usr/bin/env bash

# @description log message to file
# @arg $1 message:String the message to display
Log::logError() {
  if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_ERROR)); then
    Log::logMessage "${2:-ERROR}" "$1"
  fi
}
