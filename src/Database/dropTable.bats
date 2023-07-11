#!/usr/bin/env bash
# shellcheck disable=SC2154

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/dropTable.sh
source "${srcDir}/Database/dropTable.sh"
# shellcheck source=src/Database/query.sh
source "${srcDir}/Database/query.sh"
# shellcheck source=src/Database/newInstance.sh
source "${srcDir}/Database/newInstance.sh"
# shellcheck source=src/Conf/getAbsoluteFile.sh
source "${srcDir}/Conf/getAbsoluteFile.sh"
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

function Database::dropTable { #@test
  # shellcheck disable=SC2016
  stub mysql \
    '--defaults-extra-file= myDb -e "DROP TABLE IF EXISTS myTable" : exit 0'

  # shellcheck disable=SC2034
  declare -A dbFromInstance

  run Database::dropTable dbFromInstance 'myDb' 'myTable'
  assert_success
  assert_line --index 0 --partial "DEBUG   - execute command: 'mysql --defaults-extra-file= myDb -e DROP TABLE IF EXISTS myTable'"
  assert_line --index 1 --partial "INFO    - Table myDb.myTable has been dropped"
}
