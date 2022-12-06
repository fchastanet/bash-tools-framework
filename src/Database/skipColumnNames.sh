#!/usr/bin/env bash

# Public: by default we skip the column names
# but sometimes we need column names to display some results
# disable this option temporarily and then restore it to true
#
# **Arguments**:
# * $1 - (passed by reference) database instance to use
# * $2 - 0 to disable, 1 to enable (hide column names)
Database::skipColumnNames() {
  local -n instanceSkipColumnNames=$1
  # shellcheck disable=SC2034
  instanceSkipColumnNames['SKIP_COLUMN_NAMES']="$2"
}
