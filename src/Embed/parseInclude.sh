#!/usr/bin/env bash

Embed::parseInclude() {
  local str="$1"
  local -n ref_file=$2
  local -n ref_asName=$3

  local regexp="^# INCLUDE (.+) (AS|as|As) (.+)$"
  if [[ ${str} =~ ${regexp} ]]; then
    # shellcheck disable=SC2034
    ref_file="$(echo "${BASH_REMATCH[1]}" | Filters::removeExternalQuotes)"
    # shellcheck disable=SC2034
    ref_asName="$(echo "${BASH_REMATCH[3]}" | Filters::removeExternalQuotes)"
    if [[ ! "${ref_asName}" =~ ^[A-Za-z0-9_]+$ ]]; then
      Log::displayError "Invalid instruction '${str}'. AS property name can only be composed by letters, numbers, underscore."
      return 1
    fi
  fi
}
