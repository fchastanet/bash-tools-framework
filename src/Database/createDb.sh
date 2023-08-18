#!/usr/bin/env bash

# @description create database if not already existent
#
# @arg $1 instanceCreateDb:&Map<String,String> (passed by reference) database instance to use
# @arg $2 dbName:String database name to create
#
# @exitcode 0 if success
# @exitcode 1 if query fails
# @stderr display db creation status
Database::createDb() {
  # shellcheck disable=SC2034
  local -n instanceCreateDb=$1
  local dbName="$2"

  local sql="CREATE DATABASE IF NOT EXISTS ${dbName} CHARACTER SET 'utf8' COLLATE 'utf8_general_ci'"

  if Database::query instanceCreateDb "${sql}"; then
    Log::displayInfo "Db ${dbName} has been created"
  else
    Log::displayError "Creating Db ${dbName} has failed"
    return 1
  fi
}
