#!/usr/bin/env bash

# @description filter to keep only version number from a string
# @arg $@ files:String[] the files to filter
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to files argument
# @stdout the filtered content
# shellcheck disable=SC2120
Version::parse() {
  sed -En 's/[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p' "$@" | head -n1
}
