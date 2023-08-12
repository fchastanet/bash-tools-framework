#!/usr/bin/env bash

# @description log message to file
# @arg $1 message:String the message to display
Log::logInfo() {
  Log::logMessage "${2:-INFO}" "$1"
}
