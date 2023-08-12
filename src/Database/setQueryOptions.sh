#!/usr/bin/env bash

# @description set the general options to use on mysql command to query the database
# Differs than setOptions in the way that these options could change each time
#
# @arg $1 instanceSetQueryOptions:&Map<String,String> (passed by reference) database instance to use
# @arg $2 optionsList:String query options list
Database::setQueryOptions() {
  local -n instanceSetQueryOptions=$1
  # shellcheck disable=SC2034
  instanceSetQueryOptions['QUERY_OPTIONS']="$2"
}
