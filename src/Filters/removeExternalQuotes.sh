#!/usr/bin/env bash

# @description remove quotes (" or ') from stdin
# @example
#   echo '"TEST"' => "TEST"
#   echo '"TEST"' | Filters::removeExternalQuotes # => TEST
# @arg $@ files:String[] the files to filter
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to files argument
# @stdout the filtered content
# shellcheck disable=SC2120
Filters::removeExternalQuotes() {
  sed -E $'s/^[\"\'](.+)[\"\']$/\\1/g' "$@"
}
