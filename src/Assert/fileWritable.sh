#!/usr/bin/env bash

# Checks if file can be created in folder
#

# @description Checks if file can be created in folder
# The file does not need to exist
# @arg $1 file:String
# @exitcode 1 if file is not a valid path
# @exitcode 2 if file parent's dir is not writable
# @exitcode 3 if existing file is not writable
# @see Assert::validPath
Assert::fileWritable() {
  local file="$1"

  Assert::validPath "${file}" || return 1
  if [[ -f "${file}" ]]; then
    [[ -w "${file}" ]] || return 3
  else
    [[ -w "${file%/*}" ]] || return 2
  fi

}
