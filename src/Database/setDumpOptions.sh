#!/usr/bin/env bash

# Public: set the options to use on mysqldump command
#
# **Arguments**:
# * $1 - (passed by reference) database instance to use
# * $2 - options list
Database::setDumpOptions() {
  local -n instanceSetDumpOptions=$1
  # shellcheck disable=SC2034
  instanceSetDumpOptions['DUMP_OPTIONS']="$2"
}
