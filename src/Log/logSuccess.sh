#!/usr/bin/env bash

Log::logSuccess() { :; }

if ((BASH_FRAMEWORK_LOG_LEVEL >= __LEVEL_INFO)); then
  # log message to file
  # @param {String} $1 message
  Log::logSuccess() {
    Log::logMessage "SUCCESS" "$@"
  }
fi
