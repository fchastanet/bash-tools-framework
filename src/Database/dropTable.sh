#!/usr/bin/env bash

# @description drop table if exists
#
# @arg $1 instanceDropTable:&Map<String,String> (passed by reference) database instance to use
# @arg $2 dbName:String database name on which the table will be dropped
# @arg $2 tableName:String table name to drop
#
# @exitcode 0 if success
# @exitcode 1 if query fails
# @stderr display db table deletion status
Database::dropTable() {
  # shellcheck disable=SC2034
  local -n instanceDropTable=$1
  local dbName="$2"
  local tableName="$3"
  local sql

  sql="DROP TABLE IF EXISTS ${tableName}"
  if Database::query instanceDropTable "${sql}" "${dbName}"; then
    Log::displayInfo "Table ${dbName}.${tableName} has been dropped"
  else
    Log::displayError "Dropping Table ${dbName}.${tableName} has failed"
    return 1
  fi
}
