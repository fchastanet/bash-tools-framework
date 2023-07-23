#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/setDumpOptions.sh
source "${srcDir}/Database/setDumpOptions.sh"
# shellcheck source=src/Database/dump.sh
source "${srcDir}/Database/dump.sh"
# shellcheck source=src/Database/newInstance.sh
source "${srcDir}/Database/newInstance.sh"
# shellcheck source=src/Conf/getAbsoluteFile.sh
source "${srcDir}/Conf/getAbsoluteFile.sh"
# shellcheck source=src/File/concatenatePath.sh
source "${srcDir}/File/concatenatePath.sh"

setup() {
  export TMPDIR="${BATS_RUN_TMPDIR}"
}

teardown() {
  unstub_all
}

function Database::setDumpOptions { #@test
  # shellcheck disable=SC2030
  declare -A dbFromInstance
  Database::setDumpOptions dbFromInstance "dumpOptions"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${dbFromInstance['DUMP_OPTIONS']}" = "dumpOptions" ]]

  stub mysqldump '--defaults-extra-file= dumpOptions dbName : true'
  run Database::dump dbFromInstance "dbName"
  assert_success
  assert_output --partial "DEBUG   - execute command: 'mysqldump --defaults-extra-file= dumpOptions dbName"
}
