#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/getUserDbList.sh
source "${srcDir}/Database/getUserDbList.sh"
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

function Database::getUserDbList { #@test
  # shellcheck disable=SC2016
  stub mysql \
    "--defaults-extra-file= -e * : echo \$3 > '${BATS_TEST_TMPDIR}/query'; exit 0"

  # shellcheck disable=SC2030
  declare -A dbFromInstance

  run Database::getUserDbList dbFromInstance
  assert_success
  assert_output --partial "DEBUG   - execute command: 'mysql --defaults-extra-file= -e SELECT \`schema_name\` from INFORMATION_SCHEMA.SCHEMATA WHERE \`schema_name\` NOT IN(\"information_schema\", \"mysql\", \"performance_schema\", \"sys\")"
  [[ "$(cat "${BATS_TEST_TMPDIR}/query")" = "$(cat "${BATS_TEST_DIRNAME}/testsData/getUserDbList.query")" ]]
}
