#!/usr/bin/env bash

# @description set the options to use on mysqldump command
#
# @arg $1 instanceSetDumpOptions:&Map<String,String> (passed by reference) database instance to use
# @arg $2 optionsList:String dump options list
Database::setDumpOptions() {
  local -n instanceSetDumpOptions=$1
  # shellcheck disable=SC2034
  instanceSetDumpOptions['DUMP_OPTIONS']="$2"
}
