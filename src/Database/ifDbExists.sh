#!/usr/bin/env bash

# Public: check if given database exists
#
# **Arguments**:
# * $1 (passed by reference) database instance to use
# * $2 database name
Database::ifDbExists() {
  local -n instanceIfDbExists=$1
  local dbName result
  dbName="$2"
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
