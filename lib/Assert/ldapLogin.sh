#!/usr/bin/env bash

Assert::ldapLogin() {
  local regexp="^[a-z]+$"
  if [[ $1 =~ ${regexp} ]]; then
    return 0
  else
    return 1
  fi
}
