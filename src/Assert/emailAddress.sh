#!/usr/bin/env bash

# check if param is valid email address
# @param $1 the full email address
# @return 1 on error
Assert::emailAddress() {
  local email expectedRegexp
  email="$1"
  expectedRegexp="^\S+@\S+$"

  [[ "${email}" =~ ${expectedRegexp} ]]
}
