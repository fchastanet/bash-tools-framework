#!/usr/bin/env bash

# check if param is valid asName
# @arg $1 asName:String the as name of the embedded data
# @exitcode 1 on invalid name
Embed::assertAsName() {
  local asName="$1"
  if [[ ! "${asName}" =~ ^[A-Za-z0-9_]+$ ]]; then
    Log::displayError "Invalid embed name '${asName}'. AS property name can only be composed by letters, numbers, underscore."
    return 1
  fi
}
