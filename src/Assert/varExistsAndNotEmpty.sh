#!/usr/bin/env bash

# @description checks if variable name provided exists
# @arg $1 varName:String
# @exitcode 1 if variable doesn't exist
# @exitcode 2 if variable value empty
# @exitcode 3 if variable name invalid
# @see Assert::validVariableName
# @stderr diagnostics information is displayed
Assert::varExistsAndNotEmpty() {
  local varName="$1"
  if ! Assert::validVariableName "${varName}"; then
    Log::displayError "${varName} - invalid variable name"
    return 3
  fi
  if [[ -z "${!varName+unset}" ]]; then
    Log::displayError "${varName} - not defined"
    return 1
  elif [[ -z "${!varName}" ]]; then
    Log::displayError "${varName} - please provide a value"
    return 2
  fi
}
