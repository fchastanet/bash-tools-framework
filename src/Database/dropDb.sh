#!/usr/bin/env bash

# @description drop database if exists
#
# @arg $1 instanceDropDb:&Map<String,String> (passed by reference) database instance to use
# @arg $2 dbName:String database name to drop
#
# @exitcode 0 if success
# @exitcode 1 query fails
# @stderr display db deletion status
Database::dropDb() {
  # shellcheck disable=SC2034
  local -n instanceDropDb=$1
  local dbName="$2"

  local sql="DROP DATABASE IF EXISTS ${dbName}"
  if Database::query instanceDropDb "${sql}"; then
    Log::displayInfo "Db ${dbName} has been dropped"
  else
    Log::displayError "Dropping Db ${dbName} has failed"
    return 1
  fi
}
