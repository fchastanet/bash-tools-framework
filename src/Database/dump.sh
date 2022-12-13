#!/usr/bin/env bash

# Public: dump db limited to optional table list
#
# **Arguments**:
# * $1 (passed by reference) database instance to use
# * $2 the db to dump
# * _$3(optional)_ string containing table list
#       (can be empty string in order to specify additional options)
# * _$4(optional)_ ... additional dump options
#
# **Returns**: mysqldump command status code
Database::dump() {
  # shellcheck disable=SC2178
  local -n instanceDump=$1
  shift || true
  local db="$1"
  shift || true
  # optional table list
  local optionalTableList=""
  if [[ -n "${1+x}" ]]; then
    optionalTableList="$1"
    shift || true
  fi
  local -a dumpAdditionalOptions=()
  local -a mysqlCommand=()

  # additional options
  if [[ -n "${1+x}" ]]; then
    dumpAdditionalOptions=("$@")
  fi

  mysqlCommand+=(mysqldump)
  mysqlCommand+=("--defaults-extra-file=${instanceDump['AUTH_FILE']}")
  IFS=' ' read -r -a dumpOptions <<<"${instanceDump['DUMP_OPTIONS']}"
  mysqlCommand+=("${dumpOptions[@]}")
  mysqlCommand+=("${dumpAdditionalOptions[@]}")
  mysqlCommand+=("${db}")
  # shellcheck disable=SC2206
  mysqlCommand+=(${optionalTableList})

  Log::displayDebug "execute command: '${mysqlCommand[*]}'"
  "${mysqlCommand[@]}"
  return $?
}
