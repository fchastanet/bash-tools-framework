#!/usr/bin/env bash

Assert::regexpInFile() {
  local regexp file message
  regexp="$1"
  file="$2"
  message="$3"
  if ! grep -E "${regexp}" "${file}" >/dev/null 2>&1; then
    Log::displayError "Regexp ${regexp} not found in file ${file} - ${message}"
    return 1
  fi
}
