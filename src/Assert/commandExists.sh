#!/usr/bin/env bash

# Public: check if command specified exists or return 1
# with error and message if not
#
# **Arguments**:
# * $1 commandName on which existence must be checked
# * $2 helpIfNotExists a help command to display if the command does not exist
#
# **Exit**: code 1 if the command specified does not exist
Assert::commandExists() {
  local commandName="$1"
  local helpIfNotExists="$2"

  Log::displayInfo "check ${commandName} installed"
  command -v "${commandName}" >/dev/null 2>/dev/null || {
    Log::displayError "${commandName} is not installed, please install it"
    if [[ -n "${helpIfNotExists}" ]]; then
      Log::displayInfo "${helpIfNotExists}"
    fi
    return 1
  }
  return 0
}
