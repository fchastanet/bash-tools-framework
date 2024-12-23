#!/usr/bin/env bash

# @description asserts that directory does not exist
# check if directory empty using ls -A
# if pattern provided, apply grep -v with this pattern on ls -A result
# @arg $1 directory:String
# @arg $2 pattern:String list of files considered to be present in the directory
# @env SUDO String allows to use custom sudo prefix command
# @exitcode 1 directory does not exists
# @exitcode 2 directory arg is actually a file
# @exitcode 3 directory not empty
# @env SUDO String allows to use custom sudo prefix command
# @stderr diagnostics information is displayed
# @example pattern can be .gitkeep
Assert::dirEmpty() {
  local directory="$1"
  local pattern="${2:-}"
  local -a filter=(cat)
  if [[ -n "${pattern}" ]]; then
    filter=(grep -v -E "${pattern}")
  fi
  Log::displayInfo "Checking directory ${directory} is empty"
  if ${SUDO:-} test -f "${directory}"; then
    Log::displayError "${directory} is actually a file"
    return 2
  fi
  if ! ${SUDO:-} test -d "${directory}"; then
    Log::displayError "Directory ${directory} does not exist"
    return 1
  fi
  if [[ "$(${SUDO:-} ls -A "${directory}" | "${filter[@]}")" != "" ]]; then
    if [[ -z "${pattern}" ]]; then
      Log::displayError "Directory ${directory} is not considered as empty"
    else
      Log::displayError "Directory ${directory} is not considered as empty using pattern '${pattern}'"
    fi
    return 3
  fi
}
