#!/usr/bin/env bash

# @description databases's list of given mysql server
#
# @example text
# - information_schema
# - mysql
# - performance_schema
# - sys
#
# @arg $1 instanceUserDbList:&Map<String,String> (passed by reference) database instance to use
# @stdout the list of db except mysql admin ones (see example)
# @exitcode * the query exit code
Database::getUserDbList() {
  # shellcheck disable=SC2034
  local -n instanceUserDbList=$1
  # shellcheck disable=SC2016
  local sql='SELECT `schema_name` from INFORMATION_SCHEMA.SCHEMATA WHERE `schema_name` NOT IN("information_schema", "mysql", "performance_schema", "sys")'
  Database::query instanceUserDbList "${sql}"
}
