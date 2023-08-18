#!/usr/bin/env bash

# @description mysql query on a given db
# @warning could use QUERY_OPTIONS variable from dsn if defined
# @example
#   cat file.sql | Database::query ...
# @arg $1 instanceQuery:&Map<String,String> (passed by reference) database instance to use
# @arg $2 sqlQuery:String (optional) sql query or sql file to execute. if not provided or empty, the command can be piped
# @arg $3 dbName:String (optional) the db name
#
# @exitcode mysql command status code
Database::query() {
  local -n instanceQuery=$1
  local -a mysqlCommand=()
  local -a queryOptions

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
  if [[ -n "${2+x}" && -n "$2" && ! -f "$2" ]]; then
    mysqlCommand+=("-e")
    mysqlCommand+=("$2")
  fi
  Log::displayDebug "$(printf "execute command: '%s'" "${mysqlCommand[*]}")"

  if [[ -f "$2" ]]; then
    "${mysqlCommand[@]}" <"$2"
  else
    "${mysqlCommand[@]}"
  fi
}
