#!/usr/bin/env bash

# check if param is valid dns hostname (known bug é characters are considered OK)
# @param $1 the dns hostname
# @return 1 on error
Assert::dnsHostname() {
  local regexp="^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$"
  if [[ $1 =~ ${regexp} ]]; then
    return 0
  else
    return 1
  fi
}
