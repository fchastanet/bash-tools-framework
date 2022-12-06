#!/usr/bin/env bash

Assert::fileExecutable() {
  local file, user, group
  file="$1"
  user="${2:-${USERNAME}}"
  group="${3:-${USERGROUP}}"
  assertFileExists "${file}" "${user}" "${group}" || return 1
  if [[ ! -x "${file}" ]]; then
    Log::displayError "file not executable ${file}"
    return 1
  fi
}
