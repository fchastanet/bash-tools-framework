#!/usr/bin/env bash

# Public: mysql query on a given db
#
# **Arguments**:
# * $1 (passed by reference) database instance to use
# * $2 sql query to execute.
#    if not provided or empty, the command can be piped (eg: cat file.sql | Database::query ...)
# * _$3 (optional)_ the db name
#
# **Returns**: mysql command status code
Database::query() {
  local -n instanceQuery=$1
  local -a mysqlCommand=()

  mysqlCommand+=(mysql)
  mysqlCommand+=("--defaults-extra-file=${instanceQuery['AUTH_FILE']}")
  IFS=' ' read -r -a queryOptions <<<"${instanceQuery['QUERY_OPTIONS']}"
  mysqlCommand+=("${queryOptions[@]}")
  if [[ "${instanceQuery['SKIP_COLUMN_NAMES']}" = "1" ]]; then
    mysqlCommand+=("-s" "--skip-column-names")
  fi
  # add optional db name
  if [[ -n "${3+x}" ]]; then
    mysqlCommand+=("$3")
  fi
  # add optional sql query
  if [[ -n "${2+x}" && -n "$2" ]]; then
    if [[ ! -f "$2" ]]; then
      mysqlCommand+=("-e")
      mysqlCommand+=("$2")
    fi
  fi
  Log::displayDebug "$(printf "execute command: '%s'" "${mysqlCommand[*]}")"

  if [[ -f "$2" ]]; then
    "${mysqlCommand[@]}" <"$2"
  else
    "${mysqlCommand[@]}"
  fi
}
