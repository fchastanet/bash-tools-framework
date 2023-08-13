#!/usr/bin/env bash

# @description check if argument is a valid linux path
# invalid path are those with:
# - invalid characters
# - component beginning by a - (because could be considered as a command's option)
# - not beginning with a slash
# - relative
#
# @arg $1 path:string path that needs to be checked
# @exitcode 1 if path is invalid
# @see https://regex101.com/r/afLrmM/2
# @see Assert::validPosixPath if you need more restrictive check
Assert::validPath() {
  local path="$1"

  [[ "${path}" =~ ^\/$|^(\/[.a-zA-Z_0-9][.a-zA-Z_0-9-]*)+$ ]] &&
    [[ ! "${path}" =~ (\/\.\.)|(\.\.\/)|^\.$|^\.\.$ ]] # avoid relative
}
