#!/usr/bin/env bash

# @description asserts that first argument is file that exists with specified ownership
# @arg $1 file:String
# @arg $2 user:String expected owner user name of the file (default: USERNAME or id -un command)
# @arg $3 group:String expected owner group name of the file (default: USERGROUP or id -gn command)
# @env USERNAME String if arg $2 is not provided
# @env USERGROUP String if arg $3 is not provided
# @exitcode 1 if missing file
# @exitcode 2 if incorrect user ownership
# @exitcode 3 if incorrect group ownership
# @stderr diagnostics information is displayed
Assert::fileExists() {
  local file="$1"
  local user="${2:-${USERNAME}}"
  local group="${3:-${USERGROUP}}"
  Log::displayInfo "Check ${file} exists with user ${user}:${group}"
  if [[ ! -f "${file}" ]]; then
    Log::displayError "missing file ${file}"
    return 1
  fi
  if [[ "${user}" != "$(stat -c '%U' "${file}")" ]]; then
    Log::displayError "incorrect user ownership on file ${file}"
    return 2
  fi
  if [[ "${group}" != "$(stat -c '%G' "${file}")" ]]; then
    Log::displayError "incorrect group ownership on file ${file}"
    return 3
  fi
}
