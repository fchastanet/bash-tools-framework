#!/usr/bin/env bash

Assert::fileNotExecutable() {
  local file, user, group
  file="$1"
  user="${2:-${USERNAME}}"
  group="${3:-${USERGROUP}}"
  assertFileExists "${file}" "${user}" "${group}" || return 1
  if [[ -x "${file}" ]]; then
    Log::displayError "file executable ${file}"
    return 1
  fi
}
