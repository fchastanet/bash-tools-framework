#!/usr/bin/env bash

Log::logDebug() { :; }

if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_DEBUG)); then
  # log message to file
  # @param {String} $1 message
  Log::logDebug() {
    Log::logMessage "DEBUG" "$@"
  }
fi
