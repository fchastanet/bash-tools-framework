#!/usr/bin/env bash

Assert::firstNameLastName() {
  local regexp="^[^ ]+ ([^ ]+[ ]?)+$"
  if [[ $1 =~ ${regexp} ]]; then
    return 0
  else
    return 1
  fi
}
