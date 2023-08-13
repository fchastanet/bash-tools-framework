#!/usr/bin/env bash

# @description exits with message if expected global variable is not set
# @example
#   Assert::expectGlobalVariables EXISTING_VAR EXISTING_VAR2
#
# @arg $@ expectedGlobals:String[] expected global variables
# @exitcode 1 if one of the expected global variables is not set
# @stderr disgnostics information displayed
Assert::expectGlobalVariables() {
  for var in "${@}"; do
    [[ -v "${var}" ]] || {
      Log::displayError "Variable ${var} is unset"
      return 1
    }
  done
}
