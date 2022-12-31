#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/newInstance.sh
source "${srcDir}/Database/newInstance.sh"
# shellcheck source=src/Database/checkDsnFile.sh
source "${srcDir}/Database/checkDsnFile.sh"
# shellcheck source=src/Profiles/getAbsoluteConfFile.sh
source "${srcDir}/Profiles/getAbsoluteConfFile.sh"
# shellcheck source=src/File/concatenatePath.sh
source "${srcDir}/File/concatenatePath.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
  mkdir -p "${BATS_TMP_DIR}/home/.bash-tools/dsn"
  #cd "${BATS_TMP_DIR}/home/.bash-tools/dsn" || exit 1
  cp "${BATS_TEST_DIRNAME}/testsData/dsn_"* "${BATS_TMP_DIR}/home/.bash-tools/dsn"
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/default.local.env"
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/other.local.env"
  export HOME=${BATS_TMP_DIR}/home
}

teardown() {
  unstub_all
  rm -Rf "${BATS_TMP_DIR}" || true
}

function Database::newInstance::unknown_dsn_file { #@test
  local -A dbFromInstance
  output="$(Database::newInstance dbFromInstance "unknown" 2>&1)" || status=$?
  [[ "${status}" -eq 1 ]]
  [[ "${output}" = *"ERROR   - conf file 'unknown' not found"* ]]
  [[ "${#dbFromInstance}" = "0" ]]
}

function Database::newInstance::invalid_dsn_file { #@test
  # shellcheck disable=SC2030
  local -A dbFromInstance
  local output status
  output="$(Database::newInstance dbFromInstance "dsn_missing_password" 2>&1)" || status=$?
  [[ "${status}" -eq 1 ]]
  [[ "${output}" = *"ERROR   - dsn file"* ]]
  [[ "${output}" = *"/home/.bash-tools/dsn/dsn_missing_password.env : PASSWORD not provided"* ]]
  [[ "${#dbFromInstance}" = "0" ]]
}

function Database::newInstance::defaultOptions { #@test
  local -A dbFromInstance
  Database::newInstance dbFromInstance "${BATS_TEST_DIRNAME}/testsData/dsn_valid.env"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${dbFromInstance['INITIALIZED']}" = "1" ]]
  [[ "${dbFromInstance['SKIP_COLUMN_NAMES']}" = "1" ]]
  [[ "${dbFromInstance['SSL_OPTIONS']}" = "--ssl-mode=DISABLED" ]]
  [[ "${dbFromInstance['QUERY_OPTIONS']}" = "--batch --raw --default-character-set=utf8" ]]
  [[ "${dbFromInstance['DUMP_OPTIONS']}" = "--default-character-set=utf8 --compress --hex-blob --routines --triggers --single-transaction --set-gtid-purged=OFF --column-statistics=0 --ssl-mode=DISABLED" ]]
  [[ "${dbFromInstance['DSN_FILE']}" = "${BATS_TEST_DIRNAME}/testsData/dsn_valid.env" ]]
  [[ "${dbFromInstance['DB_IMPORT_OPTIONS']}" = "--connect-timeout=5 --batch --raw --default-character-set=utf8" ]]
  [[ "$(grep 'user = ' "${dbFromInstance['AUTH_FILE']}")" = "user = root" ]]
}

function Database::newInstance::alreadyInitialized { #@test
  local -A dbFromInstance
  dbFromInstance['INITIALIZED']=1
  Database::newInstance dbFromInstance "${BATS_TEST_DIRNAME}/testsData/dsn_valid.env"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${dbFromInstance['INITIALIZED']}" = "1" ]]
  [[ "${#dbFromInstance[@]}" = "1" ]]

}

function Database::newInstance::relative_dsn_file { #@test
  local -A dbFromInstance
  Database::newInstance dbFromInstance "${BATS_TEST_DIRNAME}/../Database/testsData/dsn_valid_relative.env"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${dbFromInstance['INITIALIZED']}" = "1" ]]
  [[ "${dbFromInstance['SKIP_COLUMN_NAMES']}" = "0" ]]
  [[ "${dbFromInstance['SSL_OPTIONS']}" = "sslOptions" ]]
  [[ "${dbFromInstance['QUERY_OPTIONS']}" = "queryOptions" ]]
  [[ "${dbFromInstance['DUMP_OPTIONS']}" = "dumpOptions" ]]
  [[ "${dbFromInstance['DB_IMPORT_OPTIONS']}" = 'dbImportOptions' ]]
  [[ "${dbFromInstance['DSN_FILE']}" = "${BATS_TEST_DIRNAME}/testsData/dsn_valid_relative.env" ]]
  [[ "$(grep 'user = ' "${dbFromInstance['AUTH_FILE']}")" = "user = relative" ]]
}

function Database::newInstance::absolute_dsn_file { #@test
  local -A dbFromInstance
  Database::newInstance dbFromInstance "${BATS_TEST_DIRNAME}/testsData/dsn_valid_absolute.env"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${dbFromInstance['INITIALIZED']}" = "1" ]]
  [[ "${dbFromInstance['SKIP_COLUMN_NAMES']}" = "absoluteSkip" ]]
  [[ "${dbFromInstance['SSL_OPTIONS']}" = "absoluteSslOptions" ]]
  [[ "${dbFromInstance['QUERY_OPTIONS']}" = "absoluteQueryOptions" ]]
  [[ "${dbFromInstance['DUMP_OPTIONS']}" = "absoluteDumpOptions" ]]
  [[ "${dbFromInstance['DB_IMPORT_OPTIONS']}" = 'absoluteDbImportOptions' ]]
  [[ "${dbFromInstance['DSN_FILE']}" = "${BATS_TEST_DIRNAME}/testsData/dsn_valid_absolute.env" ]]
  [[ "$(grep 'user = ' "${dbFromInstance['AUTH_FILE']}")" = "user = absolute" ]]
}

function Database::newInstance::valid_dsnFile_from_home { #@test
  # shellcheck disable=SC2030
  local -A dbFromInstance
  Database::newInstance dbFromInstance "dsn_valid"
  status=$?

  [[ "${status}" -eq 0 ]]
  [[ "${dbFromInstance['INITIALIZED']}" = "1" ]]
  [[ "${dbFromInstance['SKIP_COLUMN_NAMES']}" = "1" ]]
  [[ "${dbFromInstance['SSL_OPTIONS']}" = "--ssl-mode=DISABLED" ]]
  [[ "${dbFromInstance['QUERY_OPTIONS']}" = "--batch --raw --default-character-set=utf8" ]]
  [[ "${dbFromInstance['DUMP_OPTIONS']}" = "--default-character-set=utf8 --compress --hex-blob --routines --triggers --single-transaction --set-gtid-purged=OFF --column-statistics=0 --ssl-mode=DISABLED" ]]
  [[ "${dbFromInstance['DSN_FILE']}" = "${BATS_TMP_DIR}/home/.bash-tools/dsn/dsn_valid.env" ]]
  [[ "${dbFromInstance['DB_IMPORT_OPTIONS']}" = "--connect-timeout=5 --batch --raw --default-character-set=utf8" ]]

  # shellcheck disable=SC2031
  [[ "${dbFromInstance['HOSTNAME']}" = "127.0.0.1" ]]
  # shellcheck disable=SC2031
  [[ "${dbFromInstance['USER']}" = "root" ]]
  # shellcheck disable=SC2031
  [[ "${dbFromInstance['PASSWORD']}" = "root" ]]
  # shellcheck disable=SC2031
  [[ "${dbFromInstance['PORT']}" = "3306" ]]

  [[ -f "${dbFromInstance['AUTH_FILE']}" ]]
  [[ "$(cat "${dbFromInstance['AUTH_FILE']}")" = "$(cat "${BATS_TEST_DIRNAME}/testsData/mysql_auth_file.cnf")" ]]
}
