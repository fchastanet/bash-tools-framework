#!/usr/bin/env bash

# Public: create database if not already existent
#
# **Arguments**:
# * $1 (passed by reference) database instance to use
# * $2 database name to create
#
# **Returns**:
# * 0 if success
# * 1 else
Database::createDb() {
  # shellcheck disable=SC2034
  local -n instanceCreateDb=$1
  local dbName, sql, result
  dbName="$2"

  sql="CREATE DATABASE IF NOT EXISTS ${dbName} CHARACTER SET 'utf8' COLLATE 'utf8_general_ci'"

  Database::query instanceCreateDb "${sql}"
  result=$?

  if [[ "${result}" == "0" ]]; then
    Log::displayInfo "Db ${dbName} has been created"
  else
    Log::displayError "Creating Db ${dbName} has failed"
  fi
  return "${result}"
}
