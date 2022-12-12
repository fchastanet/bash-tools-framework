#!/usr/bin/env bash

# Public: drop database if exists
#
# **Arguments**:
# * $1 (passed by reference) database instance to use
# * $2 database name to drop
#
# **Returns**:
# * 0 if success
# * 1 else
Database::dropDb() {
  # shellcheck disable=SC2034
  local -n instanceDropDb=$1
  local dbName sql result
  dbName="$2"

  sql="DROP DATABASE IF EXISTS ${dbName}"
  Database::query instanceDropDb "${sql}"
  result=$?

  if [[ "${result}" == "0" ]]; then
    Log::displayInfo "Db ${dbName} has been dropped"
  else
    Log::displayError "Dropping Db ${dbName} has failed"
  fi
  return "${result}"
}
