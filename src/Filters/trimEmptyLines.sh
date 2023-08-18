#!/usr/bin/env bash

# @description remove all empty lines
# - at the beginning of the file before non empty line
# - at the end of the file after last non empty line
# @arg $@ files:String[] the files to filter
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to files argument
# @stdout the filtered content
# shellcheck disable=SC2120
# @see https://unix.stackexchange.com/a/653883
Filters::trimEmptyLines() {
  awk '
    NF {print saved $0; saved = ""; started = 1; next}
    started {saved = saved $0 ORS}
  ' "$@"
}
