#!/usr/bin/env bash

Log::logWarning() { :; }

if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_WARNING)); then
  # log message to file
  # @param {String} $1 message
  Log::logWarning() {
    Log::logMessage "WARNING" "$@"
  }
fi
