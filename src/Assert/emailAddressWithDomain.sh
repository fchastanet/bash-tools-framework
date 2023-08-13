#!/usr/bin/env bash

# @description check if param is valid email address with one the specified domains
# @warning it is a very simple check, no RFC validation
# @arg $1 email:String the full email address
# @arg $@ expectedDomains:String[] the expected email address domains (no check if empty)
# @exitcode 1 if email invalid
# @exitcode 2 if email domain doesn't match the expected domains passed in arguements
# @see Assert::emailAddress
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
