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
# shellcheck source=src/Conf/getAbsoluteFile.sh
source "${srcDir}/Conf/getAbsoluteFile.sh"
# shellcheck source=src/File/concatenatePath.sh
source "${srcDir}/File/concatenatePath.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export BASH_FRAMEWORK_DISPLAY_LEVEL=4
}

teardown() {
  unstub_all
}

function Database::isTableExists::yes { #@test
  # check if table exists, this time we answer no
  # shellcheck disable=SC2016
  stub mysql \
    "--defaults-extra-file= -e * : echo \$3 > ${BATS_TEST_TMPDIR}/query ; echo '1'"

  # shellcheck disable=SC2030
  declare -A dbFromInstance

  run Database::isTableExists dbFromInstance 'myDb' 'myTable'

  assert_success
  assert_output --partial "DEBUG   - execute command: 'mysql --defaults-extra-file= -e select count(*) from information_schema.tables where table_schema='myDb' and table_name='myTable''"
  [[ -f "${BATS_TEST_TMPDIR}/query" ]]
  [[ "$(cat "${BATS_TEST_TMPDIR}/query")" = "$(cat "${BATS_TEST_DIRNAME}/testsData/isTableExists.query")" ]]
}

function Database::isTableExists::no { #@test
  # check if table exists, this time we answer no
  # shellcheck disable=SC2016
  stub mysql \
    "--defaults-extra-file= -e * : echo \$3 > ${BATS_TEST_TMPDIR}/query ; echo ''"

  # shellcheck disable=SC2030
  declare -A dbFromInstance

  run Database::isTableExists dbFromInstance 'myDb' 'myTable'

  assert_failure 1
  assert_output --partial "DEBUG   - execute command: 'mysql --defaults-extra-file= -e select count(*) from information_schema.tables where table_schema='myDb' and table_name='myTable''"
  [[ -f "${BATS_TEST_TMPDIR}/query" ]]
  [[ "$(cat "${BATS_TEST_TMPDIR}/query")" = "$(cat "${BATS_TEST_DIRNAME}/testsData/isTableExists.query")" ]]
}
