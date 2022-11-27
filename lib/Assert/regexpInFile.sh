#!/usr/bin/env bash

Assert::regexpInFile() {
  local regexp="$1"
  local file="$2"
  local message="$3"
  if ! grep -P "${regexp}" "${file}" >/dev/null 2>&1; then
    Log::displayError "Regexp ${regexp} not found in file ${file} - ${message}"
    return 1
  fi
}
