#!/usr/bin/env bash

# @description check if argument is a valid posix linux path
# and does not contains relative directory
# @warning posix path is really restrictive, if you need less restrictive check you can use Assert::validPath
# @arg $1 path:string path that needs to be checked
# @exitcode 1 if path is invalid
# @require Linux::requiresPathchk
# @require Linux::requiresRealpath
Assert::validPosixPath() {
  local path="$1"

  pathchk -p -P "${path}" && [[ "$(realpath --canonicalize-missing "${path}")" = "${path}" ]]
}
