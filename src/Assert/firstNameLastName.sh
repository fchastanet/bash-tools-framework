#!/usr/bin/env bash

# @description check if argument respects 2 or more words sperated by a space
# it supports accentuated characters and names with hyphen(-)
# @arg $1 firstnameLastname:String
# @exitcode 1 if regexp not matches
# @see https://regex101.com/r/JyyfOM/1
Assert::firstNameLastName() {
  local regexp="^[^ ]+([ ][^ ]+)+$"
  [[ $1 =~ ${regexp} ]]
}
