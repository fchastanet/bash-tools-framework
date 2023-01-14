#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/setQueryOptions.sh
source "${srcDir}/Database/setQueryOptions.sh"
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

function Database::setQueryOptions { #@test
  # shellcheck disable=SC2030
  declare -A dbFromInstance
  Database::setQueryOptions dbFromInstance "--connect-timeout=15"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${dbFromInstance['QUERY_OPTIONS']}" = "--connect-timeout=15" ]]

  stub mysql '--defaults-extra-file= --connect-timeout=15 -e "SELECT 1" : true'
  run Database::query dbFromInstance "SELECT 1"
  assert_success
  assert_output --partial "DEBUG   - execute command: 'mysql --defaults-extra-file= --connect-timeout=15 -e SELECT 1'"
}
