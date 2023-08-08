#!/usr/bin/env bash

# log message to file
# @param {String} $1 message
Log::logDebug() {
  Log::logMessage "${2:-DEBUG}" "$1"
}
