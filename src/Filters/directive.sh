#!/usr/bin/env bash

FILTER_DIRECTIVE_KEEP_ONLY_HEADERS="0"
# shellcheck disable=SC2034
FILTER_DIRECTIVE_REMOVE_HEADERS="1"

# @description filter the directive only at the beginning of the file
# we do not want to filter eventual documentation in the
# rest of the script
#
# **invert arg**
# - ${FILTER_DIRECTIVE_KEEP_ONLY_HEADERS} or 0 to keep only directive
# - ${FILTER_DIRECTIVE_REMOVE_HEADERS} or 1 to remove directive and keep the rest of the file
#
# @arg $1 invert:bool Invert the sense of matching, to select non-matching lines:
# shellcheck disable=SC2120
Filters::directive() {
  local invert="${1:-${FILTER_DIRECTIVE_KEEP_ONLY_HEADERS}}"
  shift || true
  awk -v invert="${invert}" '
    BEGIN {
      write=!invert
      headerProcessed=0
    }
    {
      line = $0
      if (/^# (BIN_FILE=|IMPLEMENT |REQUIRE |COMPATIBILITY |EMBED |FACADE|VAR_[^=]*=|EMBED ).*$/) {
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
