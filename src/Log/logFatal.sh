#!/usr/bin/env bash

# log message to file
# @param {String} $1 message
Log::logFatal() {
  Log::logMessage "${2:-FATAL}" "$@"
}
