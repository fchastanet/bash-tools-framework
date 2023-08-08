#!/usr/bin/env bash

# log message to file
# @param {String} $1 message
Log::logError() {
  Log::logMessage "${2:-ERROR}" "$1"
}
