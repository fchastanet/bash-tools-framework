#!/usr/bin/env bash

# @description asserts that directory does not exist
# @arg $1 dir:String
# @env SUDO String allows to use custom sudo prefix command
# @exitcode 1 existing dir
# @env SUDO String allows to use custom sudo prefix command
# @stderr diagnostics information is displayed
Assert::dirNotExists() {
  local dir="$1"
  Log::displayInfo "Checking directory ${dir} does not exist"
  if ${SUDO:-} test -d "${dir}" &>/dev/null; then
    Log::displayError "Directory ${dir} still exists"
    return 1
  fi
}
