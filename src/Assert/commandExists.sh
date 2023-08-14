#!/usr/bin/env bash

# @description check if command specified exists or return 1
# with error and message if not
#
# @arg $1 commandName:String on which existence must be checked
# @arg $2 helpIfNotExists:String a help command to display if the command does not exist
#
# @exitcode 1 if the command specified does not exist
# @stderr diagnostic information + help if second argument is provided
Assert::commandExists() {
  local commandName="$1"
  local helpIfNotExists="$2"

  "${BASH_FRAMEWORK_COMMAND:-command}" -v "${commandName}" >/dev/null 2>/dev/null || {
    Log::displayError "${commandName} is not installed, please install it"
    if [[ -n "${helpIfNotExists}" ]]; then
      Log::displayInfo "${helpIfNotExists}"
    fi
    return 1
  }
  return 0
}
