#!/usr/bin/env bash

# log message to file
# @param {String} $1 message
Log::logWarning() {
  Log::logMessage "WARNING" "$@"
}
