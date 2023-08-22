#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/ifDbExists.sh
source "${srcDir}/Database/ifDbExists.sh"
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

function Database::ifDbExists { #@test
  stub mysqlshow \
    '--defaults-extra-file= myDb : echo "Database: myDb"'

  declare -A dbFromInstance

  run Database::ifDbExists dbFromInstance 'myDb'
  assert_success
  assert_output --partial "DEBUG   - execute command: 'mysqlshow --defaults-extra-file= myDb"
}
