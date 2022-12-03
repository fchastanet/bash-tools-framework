#!/usr/bin/env bash

# Public: drop table if exists
#
# **Arguments**:
# * $1 (passed by reference) database instance to use
# * $2 database name
# * $3 table name to drop
#
# **Returns**:
# * 0 if success
# * 1 else
Database::dropTable() {
  # shellcheck disable=SC2034
  local -n instanceDropTable=$1
  local dbName, tableName, sql, result
  dbName="$2"
  tableName="$3"

  sql="DROP TABLE IF EXISTS ${tableName}"
  Database::query instanceDropTable "${sql}" "${dbName}"
  result=$?

  if [[ "${result}" == "0" ]]; then
    Log::displayInfo "Table ${dbName}.${tableName} has been dropped"
  else
    Log::displayError "Dropping Table ${dbName}.${tableName} has failed"
  fi
  return "${result}"
}
