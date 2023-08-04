#!/usr/bin/env bash

# Public: check if argument is a valid linux path
#
# @param {string} path $1 path that needs to be checked
# @return 1 if path is invalid
# invalid path are those with:
# - invalid characters
# - component beginning by a - (because option)
# - not beginning with a slash
# - relative
Assert::validPath() {
  local path="$1"

  # https://regex101.com/r/afLrmM/2
  [[ "${path}" =~ ^\/$|^(\/[.a-zA-Z_0-9][.a-zA-Z_0-9-]*)+$ ]] &&
    [[ ! "${path}" =~ (\/\.\.)|(\.\.\/)|^\.$|^\.\.$ ]] # avoid relative
}
