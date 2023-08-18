#!/usr/bin/env bash

# @description remove shebang line, empty lines
# and comment lines (just the ones with spaces or not before the #
# Note: comment after command is more difficult to remove because complicated case could occur
# Eg: # inside strings like in "sed -E -e 's/#/....."
# @arg $@ files:String[] the files to filter
# @exitcode * if one of the filter command fails
# @stdin you can use stdin as alternative to files argument
# @stdout the lines filtered
# shellcheck disable=SC2120
Filters::optimizeShFile() {
  sed -E '1d' "$@" | Filters::removeEmptyLines | Filters::commentLines
  # ensure we have at least one empty line between 2 functions
  echo
}
