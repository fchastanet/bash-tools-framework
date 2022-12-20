#!/usr/bin/env bash

# Retry a command several times depending on parameters
# @param {int}    $1 max retries
# @param {int}    $2 delay between attempt
# @param {String} $3 message to display to describe the attempt
# @param ...      $@ rest of parameters, the command to run
# @return 0 on success, 1 if max retries count reached
Retry::parameterized() {
  local maxRetries=$1
  shift || true
  local delayBetweenTries=$1
  shift || true
  local message="$1"
  shift || true
  local retriesCount=1
  while true; do
    Log::displayInfo "Attempt ${retriesCount}/${maxRetries}: ${message}"
    if "$@"; then
      break
    elif ((retriesCount < maxRetries)); then
      Log::displayWarning "Command failed. Wait for ${delayBetweenTries} seconds"
      ((retriesCount++))
      sleep "${delayBetweenTries}"
    else
      Log::displayError "The command has failed after ${retriesCount} attempts."
      return 1
    fi
  done
  return 0
}
