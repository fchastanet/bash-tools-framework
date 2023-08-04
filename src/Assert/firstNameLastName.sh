#!/usr/bin/env bash

Assert::firstNameLastName() {
  local regexp
  # https://regex101.com/r/JyyfOM/1
  regexp="^[^ ]+([ ][^ ]+)+$"
  [[ $1 =~ ${regexp} ]]
}
