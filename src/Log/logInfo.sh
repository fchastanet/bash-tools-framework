#!/usr/bin/env bash

# log message to file
# @param {String} $1 message
Log::logInfo() {
  Log::logMessage "INFO" "$@"
}
