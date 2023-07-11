#!/usr/bin/env bash

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
