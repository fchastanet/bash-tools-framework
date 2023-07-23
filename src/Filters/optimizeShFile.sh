#!/usr/bin/env bash

# remove shebang line
# remove empty lines
# remove comment lines (just the ones with spaces or not the #
# Note: comment after command is more difficult to remove because complicated case could occur
# Eg: # inside strings like in "sed -E -e 's/#/....."
Filters::optimizeShFile() {
  sed -E '1d' "$@" | Filters::removeEmptyLines | Filters::commentLines
  # ensure we have at least one empty line between 2 functions
  echo
}
