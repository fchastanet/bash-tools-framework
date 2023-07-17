#!/usr/bin/env bash

# Public: check if argument is a valid linux path
#
# @param {string} path $1 path that needs to be checked
# @return 1 if path is invalid
# invalid path are those with:
# - invalid characters
# - component beggining by a - (because option)
# - not beggining with a slash
# - path not matching pathchk -P command
Assert::validPath() {
  local path="$1"

  # https://regex101.com/r/afLrmM/1
  [[ "${path}" =~ ^\/$|^(\/[a-zA-Z_0-9][a-zA-Z_0-9-]*)+$ ]] && pathchk -P "${path}"
}