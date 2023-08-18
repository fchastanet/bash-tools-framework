#!/usr/bin/env bash

# @description asserts that first argument is a file that exists with specified ownership and is executable
# @arg $1 file:String
# @arg $2 user:String expected owner user name of the file (default: USERNAME or id -un command)
# @arg $3 group:String expected owner group name of the file (default: USERGROUP or id -gn command)
# @env USERNAME String if arg $2 is not provided
# @env USERGROUP String if arg $3 is not provided
# @exitcode 1 if Assert::fileExists fails
# @exitcode 2 if file is not executable
# @stderr diagnostics information is displayed
# @see Assert::fileExists
Assert::fileExecutable() {
  local file user group
  file="$1"
  user="${2:-${USERNAME}}"
  group="${3:-${USERGROUP}}"

  Assert::fileExists "${file}" "${user}" "${group}" || return 1
  if [[ ! -x "${file}" ]]; then
    Log::displayError "file ${file} is expected to be executable"
    return 2
  fi
}
