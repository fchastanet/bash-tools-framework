#!/usr/bin/env bash

# @description exits with message if expected global variable is not set
#
# @arg $@ expectedGlobals:String[] expected global variables
#
# @exitcode 1 if one of the expected global variables is not set
Assert::expectGlobalVariables() {
  for var in "${@}"; do
    [[ -v "${var}" ]] || Log::fatal "Variable ${var} is unset"
  done
}
