#!/usr/bin/env bash

# log message to file
# @param {String} $1 message
Log::logSkipped() {
  Log::logMessage "${2:-SKIPPED}" "$@"
}
