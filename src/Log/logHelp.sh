#!/usr/bin/env bash

# @description log message to file
# @arg $1 message:String the message to display
Log::logHelp() {
  if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_INFO)); then
    Log::logMessage "${2:-HELP}" "$1"
  fi
}
