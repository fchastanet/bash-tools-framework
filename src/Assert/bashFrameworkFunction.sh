#!/usr/bin/env bash

# @description assert that first arg respects this bash framework naming convention
# @arg $1 bashFrameworkFunction:String the function's name to assert
# @exitcode 1 if bashFrameworkFunction arg doesn't respect this bash framework naming convention
Assert::bashFrameworkFunction() {
  local bashFrameworkFunction="$1"
  local expectedRegexp="^([A-Za-z0-9_]+[A-Za-z0-9_-]*::)+([a-zA-Z0-9_-]+)\$"

  [[ "${bashFrameworkFunction}" =~ ${expectedRegexp} ]]
}
