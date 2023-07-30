#!/usr/bin/env bash

readonly FILTER_META_DATA_KEEP_ONLY_HEADERS="0"
# shellcheck disable=SC2034
readonly FILTER_META_DATA_REMOVE_HEADERS="1"

# filter the metadata only at the beginning of the file
# we do not want to filter eventual documentation in the
# rest of the script
# @param {bool} invert $1 Invert the sense of matching,
# to select non-matching lines:
# - 0 to keep only metadata
# - 1 to remove metadata and keep the rest of the file
# shellcheck disable=SC2120
Filters::metadata() {
  local invert="${1:-${FILTER_META_DATA_KEEP_ONLY_HEADERS}}"
  shift || true
  awk -v invert="${invert}" '
    BEGIN {
      write=!invert
      headerProcessed=0
    }
    {
      line = $0
      if (/^# (BIN_FILE=|META_[^=]*=|EMBED ).*$/) {
        write=(invert==0) || (headerProcessed==1)
      } else if (/^#!/) {
        write=invert
      } else {
        if (invert == 0) {
          # optimization no need to process more lines
          exit 0
        }
        headerProcessed=1
        write=invert
      }
      if (write==1) {
        print line
      } else {
        next
      }
    }
  ' "$@" || test $? = 1
}
