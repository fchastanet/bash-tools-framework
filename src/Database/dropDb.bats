#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/dropDb.sh
source "${srcDir}/Database/dropDb.sh"
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

function Database::dropDb { #@test
  # shellcheck disable=SC2016
  stub mysql \
    "--defaults-extra-file=  -e 'DROP DATABASE IF EXISTS myDb' : exit 0"

  # shellcheck disable=SC2030
  declare -A dbFromInstance

  run Database::dropDb dbFromInstance 'myDb'
  assert_success
  assert_line --index 0 --partial "DEBUG   - execute command: 'mysql --defaults-extra-file= -e DROP DATABASE IF EXISTS myDb'"
  assert_line --index 1 --partial "INFO    - Db myDb has been dropped"
}
