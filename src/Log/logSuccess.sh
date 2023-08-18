#!/usr/bin/env bash

# @description log message to file
# @arg $1 message:String the message to display
Log::logSuccess() {
  Log::logMessage "${2:-SUCCESS}" "$1"
}
