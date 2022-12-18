#!/usr/bin/env bash

Log::logFatal() {
  Log::fatal "$1"
}

if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_ERROR)); then
  # log message to file
  # @param {String} $1 message
  Log::logFatal() {
    Log::logMessage "FATAL" "$@"
  }
fi
