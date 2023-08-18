#!/usr/bin/env bash

# @description remove leading and trailing spaces of a string
# @arg $@ files:String[] the files to filter
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to files argument
# @stdout the filtered content
# shellcheck disable=SC2120
Filters::trimString() {
  sed -E -e 's/^[[:space:]]*//;s/[[:space:]]*$//' "$@"
}
