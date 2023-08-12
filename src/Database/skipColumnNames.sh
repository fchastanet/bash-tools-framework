#!/usr/bin/env bash

# @description by default we skip the column names
# but sometimes we need column names to display some results
# disable this option temporarily and then restore it to true
#
# @arg $1 instanceSetQueryOptions:&Map<String,String> (passed by reference) database instance to use
# @arg $2 skipColumnNames:Boolean 0 to disable, 1 to enable (hide column names)
Database::skipColumnNames() {
  local -n instanceSkipColumnNames=$1
  # shellcheck disable=SC2034
  instanceSkipColumnNames['SKIP_COLUMN_NAMES']="$2"
}
