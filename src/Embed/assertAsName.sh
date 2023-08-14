#!/usr/bin/env bash

# @description check if param is valid asName
# @arg $1 asName:String the as name of the embedded data
# @exitcode 1 on invalid name
# @stderr diagnostics information is displayed
Embed::assertAsName() {
  local asName="$1"
  if [[ ! "${asName}" =~ ^[A-Za-z0-9_]+$ ]]; then
    Log::displayError "Invalid embed name '${asName}'. AS property name can only be composed by letters, numbers, underscore."
    return 1
  fi
}
