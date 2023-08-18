#!/usr/bin/env bash

# @description check if table exists on given db
#
# @arg $1 instanceIsTableExists:&Map<String,String> (passed by reference) database instance to use
# @arg $2 dbName:String database name
# @arg $3 tableThatShouldExists:String the table that should exists on this db
#
# @exitcode 0 if table exists
# @exitcode 1 if table doesn't exist
Database::isTableExists() {
  # shellcheck disable=SC2034
  local -n instanceIsTableExists=$1
  local dbName="$2"
  local tableThatShouldExists="$3"

  local sql="select count(*) from information_schema.tables where table_schema='${dbName}' and table_name='${tableThatShouldExists}'"
  [[ "$(Database::query instanceIsTableExists "${sql}")" = "1" ]]
}
