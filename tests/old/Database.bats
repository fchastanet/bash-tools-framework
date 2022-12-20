#!/usr/bin/env bash

SRC_FOLDER="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/src"
# shellcheck source=/src/Framework/loadEnv.sh
BASH_FRAMEWORK_ENV_FILEPATH="" source "${SRC_FOLDER}/Framework/loadEnv.sh" || exit 1

# shellcheck source=/src/Database/checkDsnFile.sh
source "${SRC_FOLDER}/Database/checkDsnFile.sh"
# shellcheck source=/src/Database/createDb.sh
source "${SRC_FOLDER}/Database/createDb.sh"
# shellcheck source=/src/Database/dropDb.sh
source "${SRC_FOLDER}/Database/dropDb.sh"
# shellcheck source=/src/Database/dropTable.sh
source "${SRC_FOLDER}/Database/dropTable.sh"
# shellcheck source=/src/Database/dump.sh
source "${SRC_FOLDER}/Database/dump.sh"
# shellcheck source=/src/Database/getUserDbList.sh
source "${SRC_FOLDER}/Database/getUserDbList.sh"
# shellcheck source=/src/Database/ifDbExists.sh
source "${SRC_FOLDER}/Database/ifDbExists.sh"
# shellcheck source=/src/Database/isTableExists.sh
source "${SRC_FOLDER}/Database/isTableExists.sh"
# shellcheck source=/src/Database/newInstance.sh
source "${SRC_FOLDER}/Database/newInstance.sh"
# shellcheck source=/src/Database/query.sh
source "${SRC_FOLDER}/Database/query.sh"
# shellcheck source=/src/Database/setDumpOptions.sh
source "${SRC_FOLDER}/Database/setDumpOptions.sh"
# shellcheck source=/src/Database/setQueryOptions.sh
source "${SRC_FOLDER}/Database/setQueryOptions.sh"
# shellcheck source=/src/Database/skipColumnNames.sh
source "${SRC_FOLDER}/Database/skipColumnNames.sh"

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../../vendor" && pwd)"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

setup() {
  (
    mkdir -p /tmp/home/.bash-tools/dsn
    cd /tmp/home/.bash-tools/dsn || exit 1
    cp "${BATS_TEST_DIRNAME}/data/dsn_"* "/tmp/home/.bash-tools/dsn"
    touch default.local.env
    touch other.local.env
  )
}

teardown() {
  rm -Rf /tmp/home || true
  unstub_all
}

function database_framework_is_loaded { #@test
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
}

function database_checkDsnFile_file_not_found { #@test
  run Database::checkDsnFile "notFound" 2>&1
  [[ "${status}" -eq 1 ]]
  # shellcheck disable=SC2154
  [[ "${output}" == *"dsn file notFound not found"* ]]
}

function database_checkDsnFile_missing_hostname { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/data/dsn_missing_hostname.env" 2>&1
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"ERROR - dsn file ${BATS_TEST_DIRNAME}/data/dsn_missing_hostname.env : HOSTNAME not provided"* ]]
}

function database_checkDsnFile_warning_hostname_localhost { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/data/dsn_hostname_localhost.env" 2>&1
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"WARN  - dsn file ${BATS_TEST_DIRNAME}/data/dsn_hostname_localhost.env : check that HOSTNAME should not be 127.0.0.1 instead of localhost"* ]]
}

function database_checkDsnFile_missing_port { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/data/dsn_missing_port.env" 2>&1
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"ERROR - dsn file ${BATS_TEST_DIRNAME}/data/dsn_missing_port.env : PORT not provided"* ]]
}

function database_checkDsnFile_invalid_port { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/data/dsn_invalid_port.env" 2>&1
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"ERROR - dsn file ${BATS_TEST_DIRNAME}/data/dsn_invalid_port.env : PORT invalid"* ]]
}

function database_checkDsnFile_missing_user { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/data/dsn_missing_user.env" 2>&1
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"ERROR - dsn file ${BATS_TEST_DIRNAME}/data/dsn_missing_user.env : USER not provided"* ]]
}

function database_checkDsnFile_missing_password { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/data/dsn_missing_password.env" 2>&1
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"ERROR - dsn file ${BATS_TEST_DIRNAME}/data/dsn_missing_password.env : PASSWORD not provided"* ]]
}

function database_checkDsnFile_valid { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/data/dsn_valid.env" 2>&1
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "" ]]
}

function database_newInstance_unknown_dsn_file { #@test
  local -A dbFromInstance
  HOME=/tmp/home run Database::newInstance dbFromInstance "unknown"
  [[ "${status}" -eq 1 ]]
}

function database_newInstance_relative_dsn_file { #@test
  local -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "../../../../tests/bash-framework/data/dsn_valid_relative.env"
  status=$?
  [[ "${status}" -eq 0 ]]
  [[ "${dbFromInstance['INITIALIZED']}" = "1" ]]
  [[ "${dbFromInstance['SKIP_COLUMN_NAMES']}" = "1" ]]
  [[ "${dbFromInstance['SSL_OPTIONS']}" = "sslOptions" ]]
  [[ "${dbFromInstance['QUERY_OPTIONS']}" = "queryOptions" ]]
  [[ "${dbFromInstance['DUMP_OPTIONS']}" = "dumpOptions" ]]
  [[ "${dbFromInstance['DSN_FILE']}" = "${BATS_TEST_DIRNAME}/data/dsn_valid_relative.env" ]]
  [[ "$(grep 'user = ' "${dbFromInstance['AUTH_FILE']}")" = "user = relative" ]]
}

function database_newInstance_absolute_dsn_file { #@test
  local -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "${BATS_TEST_DIRNAME}/data/dsn_valid_absolute.env"
  status=$?
  [[ "${status}" -eq 0 ]]
  [[ "${dbFromInstance['INITIALIZED']}" = "1" ]]
  [[ "${dbFromInstance['SKIP_COLUMN_NAMES']}" = "1" ]]
  [[ "${dbFromInstance['SSL_OPTIONS']}" = "sslOptionsAbsolute" ]]
  [[ "${dbFromInstance['QUERY_OPTIONS']}" = "queryOptionsAbsolute" ]]
  [[ "${dbFromInstance['DUMP_OPTIONS']}" = "dumpOptionsAbsolute" ]]
  [[ "${dbFromInstance['DSN_FILE']}" = "${BATS_TEST_DIRNAME}/data/dsn_valid_absolute.env" ]]
  [[ "$(grep 'user = ' "${dbFromInstance['AUTH_FILE']}")" = "user = absolute" ]]
}

function database_newInstance_invalid_dsn_file { #@test
  # shellcheck disable=SC2030
  local -A dbFromInstance
  run Database::newInstance dbFromInstance "dsn_missing_password"
  [[ "${status}" -eq 1 ]]
  # TODO check if dbFromInstance empty
}

function database_newInstance_valid_dsnFile_from_framework { #@test
  # shellcheck disable=SC2030
  local -A dbFromInstance
  run Database::newInstance dbFromInstance "default.local"
  [[ "${status}" -eq 0 ]]
  # TODO check if dbFromInstance correctly initialized
}

function database_newInstance_valid_dsn_file_from_home { #@test
  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"
  status=$?
  [[ "${status}" -eq 0 ]]
  [[ "${dbFromInstance['INITIALIZED']}" = "1" ]]
  [[ "${dbFromInstance['SKIP_COLUMN_NAMES']}" = "1" ]]
  [[ "${dbFromInstance['SSL_OPTIONS']}" = "--ssl-mode=DISABLED" ]]
  [[ "${dbFromInstance['DUMP_OPTIONS']}" = "--default-character-set=utf8 --compress --hex-blob --routines --triggers --single-transaction --set-gtid-purged=OFF --column-statistics=0 --ssl-mode=DISABLED" ]]
  [[ "${dbFromInstance['DSN_FILE']}" = "/tmp/home/.bash-tools/dsn/dsn_valid.env" ]]
  [[ ${dbFromInstance['AUTH_FILE']} = /tmp/mysql.* ]]

  [[ "${dbFromInstance['HOSTNAME']}" = "127.0.0.1" ]]
  [[ "${dbFromInstance['USER']}" = "root" ]]
  [[ "${dbFromInstance['PASSWORD']}" = "root" ]]
  [[ "${dbFromInstance['PORT']}" = "3306" ]]

  [[ -f "${dbFromInstance['AUTH_FILE']}" ]]
  [[ "${dbFromInstance['QUERY_OPTIONS']}" = "--batch --raw --default-character-set=utf8" ]]
  [[ "$(cat "${dbFromInstance['AUTH_FILE']}")" = "$(cat "${BATS_TEST_DIRNAME}/data/mysql_auth_file.cnf")" ]]
}

function database_authFile_valid_dsn_file_from_home { #@test
  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"
  status=$?
  [[ "${status}" -eq 0 ]]

  [[ "$(cat "${dbFromInstance['AUTH_FILE']}")" = "$(cat "${BATS_TEST_DIRNAME}/data/mysql_auth_file.cnf")" ]]
}

function database_skipColumnNames { #@test
  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::skipColumnNames dbFromInstance "0"
  status=$?
  [[ "${status}" -eq 0 ]]
  [[ "${dbFromInstance['SKIP_COLUMN_NAMES']}" = "0" ]]
  stub mysql '--defaults-extra-file= -e SELECT\ 1 : true'
  run Database::query dbFromInstance "SELECT 1"

  # TODO use run
  Database::skipColumnNames dbFromInstance "1"
  status=$?
  [[ "${status}" -eq 0 ]]
  [[ "${dbFromInstance['SKIP_COLUMN_NAMES']}" = "1" ]]
  stub mysql '--defaults-extra-file= -s --skip-column-names -e SELECT\ 1 : true'
  run Database::query dbFromInstance "SELECT 1"
}

function database_setDumpOptions { #@test
  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"
  status=$?
  [[ "${status}" -eq 0 ]]
  Database::setDumpOptions dbFromInstance "test"
  [[ "${dbFromInstance['DUMP_OPTIONS']}" = "test" ]]
}

function database_setQueryOptions { #@test
  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"
  status=$?
  [[ "${status}" -eq 0 ]]
  Database::setQueryOptions dbFromInstance "test"
  [[ "${dbFromInstance['QUERY_OPTIONS']}" = "test" ]]
}

function database_newInstance_auth_files_should_be_deleted { #@test
  declare authFile1=""
  declare authFile2=""
  (
    declare -A dbFromInstance1
    declare -A dbFromInstance2
    HOME=/tmp/home Database::newInstance dbFromInstance1 "dsn_valid"
    HOME=/tmp/home Database::newInstance dbFromInstance2 "dsn_valid"
    authFile1="${dbFromInstance1['AUTH_FILE']}"
    authFile2="${dbFromInstance2['AUTH_FILE']}"
    [[ -f "${authFile1}" ]]
    [[ -f "${authFile2}" ]]
    # we write variables in files as values will be lost outside of this subShell
    echo -n "${authFile1}" >/tmp/home/authFile1
    echo -n "${authFile2}" >/tmp/home/authFile2
  )
  [[ -f /tmp/home/authFile1 ]]
  [[ -f /tmp/home/authFile2 ]]
  authFile1="$(cat /tmp/home/authFile1)"
  authFile2="$(cat /tmp/home/authFile2)"
  [[ -n "${authFile1}" ]]
  [[ -n "${authFile2}" ]]
  [[ ! -f "${authFile1}" ]]
  [[ ! -f "${authFile2}" ]]
}

function database_ifDbExists_exists { #@test
  # call 2: check if from db exists, this time we answer no
  stub mysqlshow \
    '* --ssl-mode=DISABLED myDb : echo "Database: myDb"'

  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"

  run Database::ifDbExists dbFromInstance 'myDb'
  [[ "${status}" -eq 0 ]]
}

function database_isTableExists_exists { #@test
  # call 2: check if from db exists, this time we answer no
  # shellcheck disable=SC2016
  stub mysql \
    '* --batch --raw --default-character-set=utf8 -s --skip-column-names -e * : echo $8 > /tmp/home/query ; echo "1"'

  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"

  run Database::isTableExists dbFromInstance 'myDb' 'myTable'
  [[ "${status}" -eq 0 ]]
  [[ -f "/tmp/home/query" ]]
  [[ "$(cat /tmp/home/query)" == "$(cat "${BATS_TEST_DIRNAME}/data/isTableExists.query")" ]]
}

function database_isTableExists_not_exists { #@test
  # call 2: check if from db exists, this time we answer no
  # shellcheck disable=SC2016
  stub mysql \
    '* --batch --raw --default-character-set=utf8 -s --skip-column-names -e * : echo $8 > /tmp/home/query ; echo ""'

  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"

  run Database::isTableExists dbFromInstance 'myDb' 'myTable'
  [[ "${status}" -eq 1 ]]
  [[ -f "/tmp/home/query" ]]
  [[ "$(cat /tmp/home/query)" == "$(cat "${BATS_TEST_DIRNAME}/data/isTableExists.query")" ]]
}

function database_createDb { #@test
  # shellcheck disable=SC2016
  stub mysql \
    '* --batch --raw --default-character-set=utf8 -s --skip-column-names -e * : echo $8 > /tmp/home/query ; echo "Database: myDb"'

  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"

  run Database::createDb dbFromInstance 'myDb'
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Db myDb has been created"* ]]
  [[ -f "/tmp/home/query" ]]
  [[ "$(cat /tmp/home/query)" == "$(cat "${BATS_TEST_DIRNAME}/data/createDb.query")" ]]
}

function database_dropDb { #@test
  # shellcheck disable=SC2016
  stub mysql \
    '* --batch --raw --default-character-set=utf8 -s --skip-column-names -e * : echo $8 > /tmp/home/query ; echo "Database: myDb"'

  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"

  run Database::dropDb dbFromInstance 'myDb'
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Db myDb has been dropped"* ]]
  [[ -f "/tmp/home/query" ]]
  [[ "$(cat /tmp/home/query)" == "$(cat "${BATS_TEST_DIRNAME}/data/dropDb.query")" ]]
}

function database_dropTable { #@test
  # shellcheck disable=SC2016
  stub mysql \
    '* --batch --raw --default-character-set=utf8 -s --skip-column-names myDb -e * : echo $9 > /tmp/home/query ; echo "Database: myDb"'

  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"
  run Database::dropTable dbFromInstance 'myDb' 'myTable'
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Table myDb.myTable has been dropped"* ]]
  [[ -f "/tmp/home/query" ]]
  [[ "$(cat /tmp/home/query)" == "$(cat "${BATS_TEST_DIRNAME}/data/dropTable.query")" ]]
}

function database_dump { #@test
  stub mysqldump \
    '* --default-character-set=utf8 --compress --hex-blob --routines --triggers --single-transaction --set-gtid-purged=OFF --column-statistics=0 --ssl-mode=DISABLED myDb : echo "dump"'
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"
  run Database::dump dbFromInstance 'myDb'

  [[ "${status}" -eq 0 ]]
  [[ "${output}" = "dump" ]]
}

function database_dump_with_table_list { #@test
  stub mysqldump \
    '* --default-character-set=utf8 --compress --hex-blob --routines --triggers --single-transaction --set-gtid-purged=OFF --column-statistics=0 --ssl-mode=DISABLED myDb table1 table2 : echo "dump table1 table2"'

  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"
  run Database::dump dbFromInstance 'myDb' "table1 table2"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" = "dump table1 table2" ]]
}

function database_dump_with_additional_options { #@test
  # shellcheck disable=SC2016
  stub mysqldump \
    '* --default-character-set=utf8 --compress --hex-blob --routines --triggers --single-transaction --set-gtid-purged=OFF --column-statistics=0 --ssl-mode=DISABLED --no-create-info --skip-add-drop-table --single-transaction=TRUE myDb : echo "dump additional options"'

  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"
  run Database::dump dbFromInstance 'myDb' "" --no-create-info --skip-add-drop-table --single-transaction=TRUE

  [[ "${status}" -eq 0 ]]
  [[ "${output}" = "dump additional options" ]]
}

function database_getUserDbList { #@test
  # shellcheck disable=SC2016
  stub mysql \
    '* --batch --raw --default-character-set=utf8 -s --skip-column-names -e * : echo $8 > /tmp/home/query ; true'

  # shellcheck disable=SC2030
  declare -A dbFromInstance
  HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"
  run Database::getUserDbList dbFromInstance

  [[ "${status}" -eq 0 ]]
  [[ -f "/tmp/home/query" ]]
  [[ "$(cat /tmp/home/query)" == "$(cat "${BATS_TEST_DIRNAME}/data/getUserDbList.query")" ]]
}
