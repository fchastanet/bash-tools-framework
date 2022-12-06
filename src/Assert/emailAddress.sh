#!/usr/bin/env bash

# check if param is valid email address without @ part
# @param $1 the full email address
# @param $2 the expected email address domain
# @return 1 on error
Assert::emailAddress() {
  local email, expectedDomain, expectedRegexp
  local -a splitEmail
  email="$1"
  expectedDomain="$2"
  expectedRegexp="^[A-Za-z0-9._%+-]+$"

  # shellcheck disable=SC2206
  splitEmail=(${email//@/ })
  [[ "${splitEmail[0]}" =~ ${expectedRegexp} && "${splitEmail[1]}" = "${expectedDomain}" ]]
}
