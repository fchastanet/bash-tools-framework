#!/usr/bin/env bash

# check if param is valid asName
# @param $1 the as name of the embedded data
# @return 1 on invalid name
Embed::assertAsName() {
  local asName="$1"
  if [[ ! "${asName}" =~ ^[A-Za-z0-9_]+$ ]]; then
    Log::displayError "Invalid embed name '${asName}'. AS property name can only be composed by letters, numbers, underscore."
    return 1
  fi
}
