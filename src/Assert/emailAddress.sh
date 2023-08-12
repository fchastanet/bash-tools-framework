#!/usr/bin/env bash

# check if param is valid email address
# @arg $1 emailAddress:String the full email address
# @exitcode 1 on error
Assert::emailAddress() {
  local expectedRegexp="^\S+@\S+$"

  [[ "$1" =~ ${expectedRegexp} ]]
}
