#!/usr/bin/env bash

# retrieve the directive value for given directive name
# @arg $1 directiveName:string the directive name to retrieve
# @stdout the value after equals sign (spaces and quotes trimmed)
# @exitcode 1 if the directive is not found
Filters::directiveValue() {
  local directiveName="$1"
  shift || true
  grep -m 1 -E "^# ${directiveName}[ \t]*=" "$@" |
    # https://regex101.com/r/1opgGH/1
    sed -E $'s/^#[^=]+=[ \t"\']*(.*)$/\\1/' |
    sed -E $'s/[ \t"\']*$//'
}
