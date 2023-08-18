#!/usr/bin/env bash

# @description Display message using skip color (yellow)
# @arg $1 message:String the message to display
Log::displaySkipped() {
  echo -e "${__SKIPPED_COLOR}SKIPPED - ${1}${__RESET_COLOR}" >&2
  Log::logSkipped "$1"
}
