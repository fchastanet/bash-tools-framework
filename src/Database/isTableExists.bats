#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/isTableExists.sh
source "${srcDir}/Database/isTableExists.sh"
# shellcheck source=src/Database/query.sh
source "${srcDir}/Database/query.sh"
# shellcheck source=src/Database/newInstance.sh
source "${srcDir}/Database/newInstance.sh"
# shellcheck source=src/Profiles/getAbsoluteConfFile.sh
source "${srcDir}/Profiles/getAbsoluteConfFile.sh"
# shellcheck source=src/File/concatenatePath.sh
source "${srcDir}/File/concatenatePath.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
}

teardown() {
  unstub_all
  rm -Rf "${BATS_TMP_DIR}" || true
}

function Database::isTableExists::yes { #@test
  # check if table exists, this time we answer no
  # shellcheck disable=SC2016
  stub mysql \
    "--defaults-extra-file= -e * : echo \$3 > ${BATS_TMP_DIR}/query ; echo '1'"

  # shellcheck disable=SC2030
  declare -A dbFromInstance

  run Database::isTableExists dbFromInstance 'myDb' 'myTable'

  assert_success
  assert_output --partial "DEBUG   - execute command: 'mysql --defaults-extra-file= -e select count(*) from information_schema.tables where table_schema='myDb' and table_name='myTable''"
  [[ -f "${BATS_TMP_DIR}/query" ]]
  [[ "$(cat "${BATS_TMP_DIR}/query")" = "$(cat "${BATS_TEST_DIRNAME}/testsData/isTableExists.query")" ]]
}

function Database::isTableExists::no { #@test
  # check if table exists, this time we answer no
  # shellcheck disable=SC2016
  stub mysql \
    "--defaults-extra-file= -e * : echo \$3 > ${BATS_TMP_DIR}/query ; echo ''"

  # shellcheck disable=SC2030
  declare -A dbFromInstance

  run Database::isTableExists dbFromInstance 'myDb' 'myTable'

  assert_failure 1
  assert_output --partial "DEBUG   - execute command: 'mysql --defaults-extra-file= -e select count(*) from information_schema.tables where table_schema='myDb' and table_name='myTable''"
  [[ -f "${BATS_TMP_DIR}/query" ]]
  [[ "$(cat "${BATS_TMP_DIR}/query")" = "$(cat "${BATS_TEST_DIRNAME}/testsData/isTableExists.query")" ]]
}
