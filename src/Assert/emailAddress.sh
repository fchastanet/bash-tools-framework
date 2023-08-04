#!/usr/bin/env bash

# check if param is valid email address
# @param $1 the full email address
# @return 1 on error
Assert::emailAddress() {
  local expectedRegexp="^\S+@\S+$"

  [[ "$1" =~ ${expectedRegexp} ]]
}
