#!/usr/bin/env bash

# @description Retry a command several times depending on parameters
# @arg $1 maxRetries:int    $1 max retries
# @arg $2 delay:int between attempt
# @arg $3 message:String to display to describe the attempt
# @arg $@ rest of parameters, the command to run
# @exitcode 0 on success
# @exitcode 1 if max retries count reached
# @exitcode 2 if maxRetries invalid value
Retry::parameterized() {
  local maxRetries=$1
  shift || true
  local delayBetweenTries=$1
  shift || true
  local message="$1"
  shift || true
  local retriesCount=1
  if [[ "${maxRetries}" -lt 1 ]]; then
    Log::displayError "invalid maxRetry value"
    return 2
  fi

  while true; do
    Log::displayInfo "Attempt ${retriesCount}/${maxRetries}: ${message}"
    if "$@"; then
      break
    elif [[ "${retriesCount}" -lt "${maxRetries}" ]]; then
      Log::displayDebug "Command failed. Wait for ${delayBetweenTries} seconds"
      ((retriesCount++))
      sleep "${delayBetweenTries}"
    else
      Log::displayError "The command has failed after ${retriesCount} attempts."
      return 1
    fi
  done
  return 0
}
