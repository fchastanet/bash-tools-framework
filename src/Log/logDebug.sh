#!/usr/bin/env bash

# @description log message to file
# @arg $1 message:String the message to display
Log::logDebug() {
  if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_DEBUG)); then
    Log::logMessage "${2:-DEBUG}" "$1"
  fi
}
