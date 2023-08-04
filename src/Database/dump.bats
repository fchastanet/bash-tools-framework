#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/dump.sh
source "${srcDir}/Database/dump.sh"
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
}

teardown() {
  unstub_all
}

function Database::dump { #@test
  # shellcheck disable=SC2016
  stub mysqldump \
    '--defaults-extra-file= myDb : exit 0'

  # shellcheck disable=SC2030
  declare -A dbFromInstance

  run Database::dump dbFromInstance 'myDb'
  assert_success
  assert_output --partial "DEBUG   - execute command: 'mysqldump --defaults-extra-file= myDb'"
}

function Database::dump::withTableList { #@test
  stub mysqldump \
    '--defaults-extra-file=  myDb table1 table2 : exit 0'

  # shellcheck disable=SC2030
  declare -A dbFromInstance

  run Database::dump dbFromInstance 'myDb' "table1 table2"

  assert_success
  assert_output --partial "DEBUG   - execute command: 'mysqldump --defaults-extra-file= myDb table1 table2'"
}

function Database::dump::withAdditionalOptions { #@test
  stub mysqldump \
    '--defaults-extra-file= --no-create-info --skip-add-drop-table --single-transaction=TRUE myDb : exit 0'

  # shellcheck disable=SC2030
  declare -A dbFromInstance

  run Database::dump dbFromInstance 'myDb' "" --no-create-info --skip-add-drop-table --single-transaction=TRUE

  assert_success
  assert_output --partial "DEBUG   - execute command: 'mysqldump --defaults-extra-file= --no-create-info --skip-add-drop-table --single-transaction=TRUE myDb"
}
