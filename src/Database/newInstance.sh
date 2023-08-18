#!/usr/bin/env bash

# @description create a new db instance
# Returns immediately if the instance is already initialized
#
# @arg $1 instanceNewInstance:&Map<String,String> (passed by reference) database instance to use
# @arg $2 dsn:String dsn profile - load the dsn.env profile deduced using rules defined in Conf::getAbsoluteFile
#
# @example
#   declare -Agx dbInstance
#   Database::newInstance dbInstance "default.local"
#
# @exitcode 1 if dns file not able to loaded
Database::newInstance() {
  local -n instanceNewInstance=$1
  local dsn="$2"
  local DSN_FILE

  if [[ -v instanceNewInstance['INITIALIZED'] && "${instanceNewInstance['INITIALIZED']:-0}" == "1" ]]; then
    return
  fi

  # final auth file generated from dns file
  instanceNewInstance['AUTH_FILE']=""
  instanceNewInstance['DSN_FILE']=""

  # check dsn file
  DSN_FILE="$(Conf::getAbsoluteFile "dsn" "${dsn}" "env")" || return 1
  Database::checkDsnFile "${DSN_FILE}" || return 1
  instanceNewInstance['DSN_FILE']="${DSN_FILE}"

  # shellcheck source=/src/Database/testsData/dsn_valid.env
  source "${instanceNewInstance['DSN_FILE']}"

  instanceNewInstance['USER']="${USER}"
  instanceNewInstance['PASSWORD']="${PASSWORD}"
  instanceNewInstance['HOSTNAME']="${HOSTNAME}"
  instanceNewInstance['PORT']="${PORT}"

  # generate authFile for easy authentication
  instanceNewInstance['AUTH_FILE']=$(mktemp -p "${TMPDIR:-/tmp}" -t "mysql.XXXXXXXXXXXX")
  (
    echo "[client]"
    echo "user = ${USER}"
    echo "password = ${PASSWORD}"
    echo "host = ${HOSTNAME}"
    echo "port = ${PORT}"
  ) >"${instanceNewInstance['AUTH_FILE']}"

  # some of those values can be overridden using the dsn file
  # SKIP_COLUMN_NAMES enabled by default
  instanceNewInstance['SKIP_COLUMN_NAMES']="${SKIP_COLUMN_NAMES:-1}"
  instanceNewInstance['SSL_OPTIONS']="${MYSQL_SSL_OPTIONS:---ssl-mode=DISABLED}"
  instanceNewInstance['QUERY_OPTIONS']="${MYSQL_QUERY_OPTIONS:---batch --raw --default-character-set=utf8}"
  instanceNewInstance['DUMP_OPTIONS']="${MYSQL_DUMP_OPTIONS:---default-character-set=utf8 --compress --hex-blob --routines --triggers --single-transaction --set-gtid-purged=OFF --column-statistics=0 ${instanceNewInstance['SSL_OPTIONS']}}"
  instanceNewInstance['DB_IMPORT_OPTIONS']="${DB_IMPORT_OPTIONS:---connect-timeout=5 --batch --raw --default-character-set=utf8}"

  instanceNewInstance['INITIALIZED']=1
}
