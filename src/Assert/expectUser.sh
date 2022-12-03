#!/usr/bin/env bash

# Public: exits with message if current user is not the expected one
#
# **Arguments**:
# * $1 expected user login
#
# **Exit**: code 1 if current user is not the expected one
Assert::expectUser() {
  local expectedUserName, currentUserName
  expectedUserName="$1"
  currentUserName=$(id -u -n)
  [[ "${currentUserName}" != "${expectedUserName}" ]] &&
    Log::fatal "The script must be run as ${expectedUserName}"
}
