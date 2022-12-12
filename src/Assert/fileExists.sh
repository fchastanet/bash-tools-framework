#!/usr/bin/env bash

Assert::fileExists() {
  local file user group
  file="$1"
  user="${2:-${USERNAME}}"
  group="${3:-${USERGROUP}}"
  Log::displayInfo "Check ${file} exists with user ${user}:${group}"
  if [[ ! -f "${file}" ]]; then
    Log::displayError "missing file ${file}"
    return 1
  fi
  if [[ "${user}" != "$(stat -c '%U' "${file}")" ]]; then
    Log::displayError "incorrect user ownership on file ${file}"
    return 1
  fi
  if [[ "${group}" != "$(stat -c '%G' "${file}")" ]]; then
    Log::displayError "incorrect group ownership on file ${file}"
    return 1
  fi
}
