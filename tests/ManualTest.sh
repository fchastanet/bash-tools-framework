#!/usr/bin/env bash

# test used for bats debugging purpose

BATS_TEST_DIRNAME=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
vendorDir="$(cd "${BATS_TEST_DIRNAME}/../../vendor" && pwd)"

# shellcheck source=/src/Framework/loadEnv.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/src/Framework/loadEnv.sh" || exit 1
import bash-framework/Database
# shellcheck source=/vendor/bats-mock-Flamefire/load.bash
source "${vendorDir}/bats-mock-Flamefire/load.bash" || exit 1

export HOME="/tmp/home"
(
  mkdir -p "${HOME}"
  cd "${HOME}" || exit 1
  mkdir -p \
    bin \
    .bash-tools/dsn \
    .bash-tools/dbImportDumps \
    .bash-tools/dbImportProfiles
  cp "${BATS_TEST_DIRNAME}/../tools/mocks/pv" bin
  touch bin/mysql bin/mysqldump bin/mysqlshow
  chmod +x bin/*
  mkdir -p /tmp/home/.bash-tools/dsn
  cd /tmp/home/.bash-tools/dsn || exit 1
  cp "${BATS_TEST_DIRNAME}/data/"dsn_* /tmp/home/.bash-tools/dsn
  touch default.local.env
  touch other.local.env
)
export PATH="${PATH}:/tmp/home/bin"

declare -Ax dbFromInstance
HOME=/tmp/home Database::newInstance dbFromInstance "dsn_valid"
status=$?
set -x
[[ "${status}" -eq 0 ]]
[[ "${dbFromInstance['INITIALIZED']}" = "1" ]]
[[ "${dbFromInstance['OPTIONS']}" = "--default-character-set=utf8" ]]
[[ "${dbFromInstance['SSL_OPTIONS']}" = "--ssl-mode=DISABLED" ]]
[[ "${dbFromInstance['DUMP_OPTIONS']}" = "--default-character-set=utf8 --compress --hex-blob --routines --triggers --single-transaction --set-gtid-purged=OFF --column-statistics=0 --ssl-mode=DISABLED" ]]
[[ "${dbFromInstance['DSN_FILE']}" = "/tmp/home/.bash-tools/dsn/dsn_valid.env" ]]

[[ ${dbFromInstance['AUTH_FILE']} = /tmp/mysql.* ]]
[[ -f "${dbFromInstance['AUTH_FILE']}" ]]
[[ "${dbFromInstance['DEFAULT_QUERY_OPTIONS']}" = "-s --skip-column-names --ssl-mode=DISABLED " ]]
[[ "${dbFromInstance['QUERY_OPTIONS']}" = "-s --skip-column-names --ssl-mode=DISABLED " ]]
[[ "$(cat "${dbFromInstance['DSN_FILE']}")" = "$(cat "${BATS_TEST_DIRNAME}/data/mysql_auth_file.cnf")" ]]
