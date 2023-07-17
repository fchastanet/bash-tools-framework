#!/usr/bin/env bash

# Public: check if argument is a valid posix linux path
# and does not contains relative directory
#
# @param {string} path $1 path that needs to be checked
# @return 1 if path is invalid
Assert::validPosixPath() {
  local path="$1"

  pathchk -p -P "${path}" && [[ "$(realpath --canonicalize-missing "${path}")" = "${path}" ]]
}
