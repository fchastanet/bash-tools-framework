#!/usr/bin/env bash

Embed::parseInclude() {
  local str="$1"
  local -n ref_file=$2
  local -n ref_asName=$3

  local regexp="^# INCLUDE (.+) AS (.+)$"
  if [[ ${str} =~ ${regexp} ]]; then
    # shellcheck disable=SC2034
    ref_file="$(echo "${BASH_REMATCH[1]}" | Filters::removeExternalQuotes)"
    # shellcheck disable=SC2034
    ref_asName="$(echo "${BASH_REMATCH[2]}" | Filters::removeExternalQuotes)"
  fi
}