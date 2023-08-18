#!/usr/bin/env bash

# @description check if given database exists
#
# @arg $1 instanceIfDbExists:&Map<String,String> (passed by reference) database instance to use
# @arg $2 dbName:String database name
# @exitcode 1 if db doesn't exist
# @stderr debug command
Database::ifDbExists() {
  local -n instanceIfDbExists=$1
  local dbName="$2"
  local result
  local -a mysqlCommand=()

  mysqlCommand+=(mysqlshow)
  mysqlCommand+=("--defaults-extra-file=${instanceIfDbExists['AUTH_FILE']}")
  # shellcheck disable=SC2206
  mysqlCommand+=(${instanceIfDbExists['SSL_OPTIONS']})
  mysqlCommand+=("${dbName}")
  Log::displayDebug "execute command: '${mysqlCommand[*]}'"
  result="$(MSYS_NO_PATHCONV=1 "${mysqlCommand[@]}" 2>/dev/null | grep '^Database: ' | grep -o "${dbName}")"
  [[ "${result}" = "${dbName}" ]]
}
