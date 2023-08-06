#!/usr/bin/env bash

# log message to file
# @param {String} $1 message
Log::logStatus() {
  Log::logMessage "${2:-STATUS}" "$@"
}
