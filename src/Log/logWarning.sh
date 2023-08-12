#!/usr/bin/env bash

# @description log message to file
# @arg $1 message:String the message to display
Log::logWarning() {
  Log::logMessage "${2:-WARNING}" "$1"
}
