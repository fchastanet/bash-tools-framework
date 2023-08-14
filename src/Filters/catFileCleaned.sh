#!/usr/bin/env bash

# @description remove shebang line and remove empty lines at beginning and end of file
# @warning no check is done to verify that first line is a shebang or not
# @arg $1 file:String the file to filter
# @stdout the file filtered
# shellcheck disable=SC2120
Filters::catFileCleaned() {
  # remove shebang line and remove empty lines at beginning and end of file
  sed -E '1d' "$@" | Filters::trimEmptyLines
  # ensure we have at least one empty line between 2 functions
  echo
}
