#!/usr/bin/env bash

# @description filter to keep only version number from a string
# @arg $@ files:String[] the files to filter
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to files argument
# @stdout the filtered content
# shellcheck disable=SC2120
Version::parse() {
  # match anything, print(p), exit on first match(Q)
  sed -En \
    -e 's/\x1b\[[0-9;]*[mGKHF]//g' \
    -e 's/[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/' \
    -e '//{p;Q}' \
    "$@"
}
