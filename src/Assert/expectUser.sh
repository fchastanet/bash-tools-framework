#!/usr/bin/env bash

# @description exits with message if current user is not the expected one
#
# @arg $1 expectedUserName:String expected user login
# @exitcode 1 if current user is not the expected one
# @stderr diagnostics information is displayed
Assert::expectUser() {
  local expectedUserName="$1"
  if [[ "$(id -un)" != "${expectedUserName}" ]]; then
    Log::fatal "The script must be run as ${expectedUserName}"
  fi
}
