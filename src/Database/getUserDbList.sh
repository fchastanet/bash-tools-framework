#!/usr/bin/env bash

#  Public: lis dbs of given mysql server
# **Output**:
# the list of db except mysql admin ones :
# - information_schema
# - mysql
# - performance_schema
# - sys
#
# **Arguments**:
# * $1 (passed by reference) database instance to use
Database::getUserDbList() {
  # shellcheck disable=SC2034
  local -n instanceUserDbList=$1
  # shellcheck disable=SC2016
  sql='SELECT `schema_name` from INFORMATION_SCHEMA.SCHEMATA WHERE `schema_name` NOT IN("information_schema", "mysql", "performance_schema", "sys")'
  Database::query instanceUserDbList "${sql}"
}
