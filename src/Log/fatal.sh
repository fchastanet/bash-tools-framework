#!/usr/bin/env bash

# Display message using error color (red) and exit immediately with error status 1
# @param {String} $1 message
Log::fatal() {
  Log::displayError "$1"
  exit 1
}
