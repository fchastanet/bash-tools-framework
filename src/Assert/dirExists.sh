#!/usr/bin/env bash

Assert::dirExists() {
  local dir="$1"
  local user="${2:-${USERNAME:-$(id -un)}}"
  local group="${3:-${USERGROUP:-$(id -gn)}}"
  Log::displayInfo "Check if directory ${dir} exists with user ${user}:${group}"
  if [[ ! -d "${dir}" ]]; then
    Log::displayError "missing directory ${dir}"
    return 1
  fi
  if [[ "${user}" != "$(stat -c '%U' "${dir}")" ]]; then
    Log::displayError "incorrect user ownership on directory ${dir}"
    return 1
  fi
  if [[ "${group}" != "$(stat -c '%G' "${dir}")" ]]; then
    Log::displayError "incorrect group ownership on directory ${dir}"
    return 1
  fi
}
