#!/usr/bin/env bash

# @description retrieve the directive value for given directive name
# @arg $1 directiveName:String the directive name to retrieve
# @arg $@ files:String[] the files in which the search can be done (optional)
# @stdin you can use stdin as alternative to files argument
# @stdout the value after equals sign (spaces and quotes trimmed)
# @exitcode 1 if the directive is not found
# @see https://regex101.com/r/1opgGH/1
# shellcheck disable=SC2120
Filters::directiveValue() {
  local directiveName="$1"
  shift || true
  grep -m 1 -E "^# ${directiveName}[ \t]*=" "$@" |
    # https://regex101.com/r/1opgGH/1
    sed -E $'s/^#[^=]+=[ \t"\']*(.*)$/\\1/' |
    sed -E $'s/[ \t"\']*$//'
}
