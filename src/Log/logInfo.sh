#!/usr/bin/env bash

Log::logInfo() { :; }

if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_INFO)); then
  # log message to file
  # @param {String} $1 message
  Log::logInfo() {
    Log::logMessage "INFO" "$@"
  }
fi
