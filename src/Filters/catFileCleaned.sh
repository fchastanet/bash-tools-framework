#!/usr/bin/env bash

Filters::catFileCleaned() {
  # remove shebang line and remove empty lines at beginning and end of file
  sed -E '1d' "$1" | Filters::trimEmptyLines
  # ensure we have at least one empty line between 2 functions
  echo
}
