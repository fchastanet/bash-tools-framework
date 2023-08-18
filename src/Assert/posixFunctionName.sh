#!/usr/bin/env bash

# @description assert that first arg respects posix function naming convention
# @arg $1 posixFunctionName:String the function's name to assert
# @exitcode 1 if posixFunctionName arg doesn't respect posix function naming convention
Assert::posixFunctionName() {
  local posixFunctionName="$1"
  local expectedRegexp="^[a-zA-Z_][a-zA-Z0-9_]*$"

  [[ "${posixFunctionName}" =~ ${expectedRegexp} ]]
}
