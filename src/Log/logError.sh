#!/usr/bin/env bash

Log::logError() { :; }

if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_ERROR)); then
  # log message to file
  # @param {String} $1 message
  Log::logError() {
    Log::logMessage "ERROR" "$@"
  }
fi
