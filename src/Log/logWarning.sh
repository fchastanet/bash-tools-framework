#!/usr/bin/env bash

# @description log message to file
# @arg $1 message:String the message to display
Log::logWarning() {
  if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_WARNING)); then
    Log::logMessage "${2:-WARNING}" "$1"
  fi
}
