#!/usr/bin/env bash

# @description log message to file
# @arg $1 message:String the message to display
Log::logHelp() {
  Log::logMessage "${2:-HELP}" "$1"
}
