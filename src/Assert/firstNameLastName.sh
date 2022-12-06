#!/usr/bin/env bash

Assert::firstNameLastName() {
  local regexp
  regexp="^[^ ]+ ([^ ]+[ ]?)+$"
  [[ $1 =~ ${regexp} ]]
}
