#!/usr/bin/env bash

# @description parse embed directive
# @example
#   # EMBED "srcFile" AS "targetFile"
#   # EMBED "srcDir" AS "targetDir"
#   # EMBED namespace::functions AS "myFunction"
# @arg $1 str:String the directive to parse
# @arg $2 ref_resource:&String (passed by reference) the resource to embed
# @arg $3 ref_asName:&String (passed by reference) the resource alias to embed
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
