#!/usr/bin/env bash

# Public: create a new db instance
#
# **Arguments**:
# * $1 - (passed by reference) database instance to create
# * $2 - dsn profile - load the dsn.env profile
#     absolute file is deduced using rules defined in Profiles::getAbsoluteConfFile
#
# **Example:**
# ```shell
# declare -Agx dbInstance
# Database::newInstance dbInstance "default.local"
# ```
#
# Returns immediately if the instance is already initialized
Database::newInstance() {
  local -n instanceNewInstance=$1
  local dsn
  dsn="$2"

  if [[ -v instanceNewInstance['INITIALIZED'] && "${instanceNewInstance['INITIALIZED']:-0}" == "1" ]]; then
    return
  fi

  # final auth file generated from dns file
  instanceNewInstance['AUTH_FILE']=""
  instanceNewInstance['DSN_FILE']=""

  # check dsn file
  DSN_FILE="$(Profiles::getAbsoluteConfFile "dsn" "${dsn}" "env")" || exit 1
  Database::checkDsnFile "${DSN_FILE}"
  instanceNewInstance['DSN_FILE']="${DSN_FILE}"

  # shellcheck source=tests/data/dsn_valid.env
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
  Framework::trapAdd "rm -f \"${instanceNewInstance['AUTH_FILE']}\" 2>/dev/null || true" ERR EXIT

  # some of those values can be overridden using the dsn file
  # SKIP_COLUMN_NAMES enabled by default
  instanceNewInstance['SKIP_COLUMN_NAMES']="${SKIP_COLUMN_NAMES:-1}"
  instanceNewInstance['SSL_OPTIONS']="${MYSQL_SSL_OPTIONS:---ssl-mode=DISABLED}"
  instanceNewInstance['QUERY_OPTIONS']="${MYSQL_QUERY_OPTIONS:---batch --raw --default-character-set=utf8}"
  instanceNewInstance['DUMP_OPTIONS']="${MYSQL_DUMP_OPTIONS:---default-character-set=utf8 --compress --hex-blob --routines --triggers --single-transaction --set-gtid-purged=OFF --column-statistics=0 ${instanceNewInstance['SSL_OPTIONS']}}"
  instanceNewInstance['DB_IMPORT_OPTIONS']="${DB_IMPORT_OPTIONS:---connect-timeout=5 --batch --raw --default-character-set=utf8}"

  instanceNewInstance['INITIALIZED']=1
}
