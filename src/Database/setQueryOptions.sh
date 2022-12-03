#!/usr/bin/env bash

# Public: set the general options to use on mysql command to query the database
# Differs than setOptions in the way that these options could change each time
#
# **Arguments**:
# * $1 - (passed by reference) database instance to use
# * $2 - options list
Database::setQueryOptions() {
  local -n instanceSetQueryOptions=$1
  # shellcheck disable=SC2034
  instanceSetQueryOptions['QUERY_OPTIONS']="$2"
}
