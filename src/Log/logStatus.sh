#!/usr/bin/env bash

# @description log message to file
# @arg $1 message:String the message to display
Log::logStatus() {
  Log::logMessage "${2:-STATUS}" "$1"
}
