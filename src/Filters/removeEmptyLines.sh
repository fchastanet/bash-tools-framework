#!/usr/bin/env bash

# @description remove empty lines and lines containing only spaces
# @arg $@ files:String[] the files to filter
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to files argument
# @stdout the filtered content
# shellcheck disable=SC2120
Filters::removeEmptyLines() {
  awk NF "$@"
}
