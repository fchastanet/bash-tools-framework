#!/usr/bin/env bash

Assert::commandExists() {
  local commandName="$1"
  local helpIfNotExists="$2"

  Log::displayInfo "check ${commandName} installed"
  command -v "${commandName}" >/dev/null 2>/dev/null || {
    Log::displayError "${commandName} is not installed, please install it"
    if [[ -n "${helpIfNotExists}" ]]; then
      Log::displayInfo "${helpIfNotExists}"
    fi
    return 1
  }
  return 0
}
