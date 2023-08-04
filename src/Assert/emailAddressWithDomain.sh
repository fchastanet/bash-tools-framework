#!/usr/bin/env bash

# check if param is valid email address with one the specified domains
# @param $1 the full email address
# @param $@ the expected email address domains
# @return 1 if email invalid
Assert::emailAddressWithDomain() {
  local email="$1"
  local expectedDomain
  local -a splitEmail

  shift || true

  if ! Assert::emailAddress "${email}"; then
    return 1
  fi

  if [[ $# = 0 ]]; then
    # no expected domain provided
    return 0
  fi

  # shellcheck disable=SC2206
  splitEmail=(${email//@/ })
  for expectedDomain in "$@"; do
    if [[ "${splitEmail[1]}" = "${expectedDomain}" ]]; then
      return 0
    fi
  done

  return 2
}
