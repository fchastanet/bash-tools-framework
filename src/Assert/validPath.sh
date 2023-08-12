#!/usr/bin/env bash

# @description check if argument is a valid linux path
#
# @arg $1 path:string path that needs to be checked
# @exitcode 1 if path is invalid
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
