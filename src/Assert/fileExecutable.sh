#!/usr/bin/env bash

Assert::fileExecutable() {
  local file user group
  file="$1"
  user="${2:-${USERNAME}}"
  group="${3:-${USERGROUP}}"

  Assert::fileExists "${file}" "${user}" "${group}" || return 1
  if [[ ! -x "${file}" ]]; then
    Log::displayError "file ${file} is expected to be executable"
    return 1
  fi
}
