#!/usr/bin/env bash

Assert::fileExecutable() {
  local file="$1"
  local user="${2:-${USERNAME}}"
  local group="${3:-${USERGROUP}}"
  assertFileExists "${file}" "${user}" "${group}" || return 1
  if [[ ! -x "${file}" ]]; then
    Log::displayError "file not executable ${file}"
    return 1
  fi
}
