#!/usr/bin/env bash

# @description check if param is valid email address
# @warning it is a very simple check, no RFC validation
# @arg $1 emailAddress:String the full email address
# @exitcode 1 if invalid email address
Assert::emailAddress() {
  local expectedRegexp="^\S+@\S+$"

  [[ "$1" =~ ${expectedRegexp} ]]
}
