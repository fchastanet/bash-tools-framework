#!/usr/bin/env bash

Embed::parse() {
  local str="$1"
  local -n ref_resource=$2
  local -n ref_asName=$3

  local regexp="^# EMBED (.+) (AS|as|As) (.+)$"
  if [[ ${str} =~ ${regexp} ]]; then
    # shellcheck disable=SC2034
    ref_resource="$(echo "${BASH_REMATCH[1]}" | Filters::removeExternalQuotes | envsubst)"
    # shellcheck disable=SC2034
    ref_asName="$(echo "${BASH_REMATCH[3]}" | Filters::removeExternalQuotes | envsubst)"

    Embed::assertAsName "${ref_asName}" || return 1
    Embed::assertResource "${ref_resource}" || return 2
  fi
}
