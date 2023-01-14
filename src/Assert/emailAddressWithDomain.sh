#!/usr/bin/env bash

# check if param is valid email address with one the specified domains
# @param $1 the full email address
# @param $@ the expected email address domains
# @return 1 if email invalid
Assert::emailAddressWithDomain() {
  local email expectedDomain
  local -a splitEmail
  email="$1"
  shift || true

  Assert::emailAddress "${email}" || return 1

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
