#!/usr/bin/env bash

# @description dump db limited to optional table list
#
# @arg $1 instanceDump:&Map<String,String> (passed by reference) database instance to use
# @arg $2 db:String the db to dump
# @arg $3 optionalTableList:String (optional) string containing tables list (can be empty string in order to specify additional options)
# @arg $4 dumpAdditionalOptions:String[] (optional)_ ... additional dump options
# @stderr display db sql debug
# @exitcode * mysqldump command status code
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
}
