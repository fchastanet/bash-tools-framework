#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/createDb.sh
source "${srcDir}/Database/createDb.sh"
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

function Database::createDb { #@test
  # shellcheck disable=SC2016
  stub mysql \
    "--defaults-extra-file=  -e * : echo \$3 > '${BATS_TMP_DIR}/query' ; echo 'Database: myDb'"

  # shellcheck disable=SC2030
  declare -A dbFromInstance

  run Database::createDb dbFromInstance 'myDb'
  assert_success
  assert_output --partial "Db myDb has been created"
  [[ -f "${BATS_TMP_DIR}/query" ]]
  [[ "$(cat "${BATS_TMP_DIR}/query")" == "$(cat "${BATS_TEST_DIRNAME}/testsData/createDb.query")" ]]
}
