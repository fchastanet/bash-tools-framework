#!/usr/bin/env bash

# log message to file
# @param {String} $1 message
Log::logHelp() {
  Log::logMessage "${2:-HELP}" "$1"
}
