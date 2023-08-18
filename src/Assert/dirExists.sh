#!/usr/bin/env bash

# @description asserts that first argument is directory that exists with specified ownership
# @arg $1 dir:String
# @arg $2 user:String expected owner user name of the directory (default: USERNAME or id -un command)
# @arg $3 group:String expected owner group name of the directory (default: USERGROUP or id -gn command)
# @env USERNAME String if arg $2 is not provided
# @env USERGROUP String if arg $3 is not provided
# @exitcode 1 if missing directory
# @exitcode 2 if incorrect user ownership
# @exitcode 3 if incorrect group ownership
# @stderr diagnostics information is displayed
Assert::dirExists() {
  local dir="$1"
  local user="${2:-${USERNAME:-$(id -un)}}"
  local group="${3:-${USERGROUP:-$(id -gn)}}"
  Log::displayInfo "Check if directory ${dir} exists with user ${user}:${group}"
  if [[ ! -d "${dir}" ]]; then
    Log::displayError "missing directory ${dir}"
    return 1
  fi
  if [[ "${user}" != "$(stat -c '%U' "${dir}")" ]]; then
    Log::displayError "incorrect user ownership on directory ${dir}"
    return 2
  fi
  if [[ "${group}" != "$(stat -c '%G' "${dir}")" ]]; then
    Log::displayError "incorrect group ownership on directory ${dir}"
    return 3
  fi
}
