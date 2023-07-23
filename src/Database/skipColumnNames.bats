#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/skipColumnNames.sh
source "${srcDir}/Database/skipColumnNames.sh"
# shellcheck source=src/Database/query.sh
source "${srcDir}/Database/query.sh"

setup() {
  export TMPDIR="${BATS_RUN_TMPDIR}"
}

teardown() {
  unstub_all
}

function Database::skipColumnNames { #@test
  # shellcheck disable=SC2030
  declare -A dbFromInstance
  Database::skipColumnNames dbFromInstance "0"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${dbFromInstance['SKIP_COLUMN_NAMES']}" = "0" ]]

  stub mysql '--defaults-extra-file= -e "SELECT 1" : true'
  run Database::query dbFromInstance "SELECT 1"
  assert_success
  assert_output --partial "DEBUG   - execute command: 'mysql --defaults-extra-file= -e SELECT 1'"

  Database::skipColumnNames dbFromInstance "1"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${dbFromInstance['SKIP_COLUMN_NAMES']}" = "1" ]]
  stub mysql '--defaults-extra-file= -s --skip-column-names -e "SELECT 1" : true'
  run Database::query dbFromInstance "SELECT 1"
  assert_success
  assert_output --partial "DEBUG   - execute command: 'mysql --defaults-extra-file= -s --skip-column-names -e SELECT 1'"
}
