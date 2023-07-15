#!/usr/bin/env bash

# shellcheck disable=SC2120
Filters::bashCommentLines() {
  grep -vxE '[[:blank:]]*([#].*)?' "$@" || test $? = 1
}
