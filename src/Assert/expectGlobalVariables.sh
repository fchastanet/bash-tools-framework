#!/usr/bin/env bash

# Public: exits with message if expected global variable is not set
#
# **Arguments**:
# * $1 expected global variable
#
# **Exit**: code 1 if expected global variable is not set
Assert::expectGlobalVariables() {
  for var in "${@}"; do
    [[ -v "${var}" ]] || Log::fatal "Variable ${var} is unset"
  done
}
