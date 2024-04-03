#!/usr/bin/env bash

# @description asserts that file does not exist
# @arg $1 file:String
# @env SUDO String allows to use custom sudo prefix command
# @exitcode 1 existing file
# @env SUDO String allows to use custom sudo prefix command
# @stderr diagnostics information is displayed
Assert::fileNotExists() {
  local file="$1"
  Log::displayInfo "Checking file ${file} does not exist"
  if ${SUDO:-} test -f "${file}" &>/dev/null; then
    Log::displayError "file ${file} still exists"
    return 1
  fi
}
