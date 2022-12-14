#!/usr/bin/env bash

# Public: check if table exists on given db
#
# **Arguments**:
# * $1 (passed by reference) database instance to use
# * $2 database name
# * $3 the table that should exists on this db
#
# **Returns**:
# * 0 if table $3 exists
# * 1 else
Database::isTableExists() {
  # shellcheck disable=SC2034
  local -n instanceIsTableExists=$1
  local dbName="$2"
  local tableThatShouldExists="$3"

  local sql="select count(*) from information_schema.tables where table_schema='${dbName}' and table_name='${tableThatShouldExists}'"
  [[ "$(Database::query instanceIsTableExists "${sql}")" = "1" ]]
}
