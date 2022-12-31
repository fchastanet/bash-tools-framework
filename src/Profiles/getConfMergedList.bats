#!/usr/bin/env bash

FRAMEWORK_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
vendorDir="${FRAMEWORK_DIR}/vendor"
srcDir="${FRAMEWORK_DIR}/src"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Profiles/getConfMergedList.sh
source "${srcDir}/Profiles/getConfMergedList.sh"
# shellcheck source=/src/Profiles/list.sh
source "${srcDir}/Profiles/list.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
  mkdir -p "${BATS_TMP_DIR}/home/.bash-tools/dsn"
  cp "${BATS_TEST_DIRNAME}/testsData/dsn/"* "${BATS_TMP_DIR}/home/.bash-tools/dsn"
  export HOME"=${BATS_TMP_DIR}/home"
}

teardown() {
  unstub_all
  rm -Rf "${BATS_TMP_DIR}" || true
}

function Profiles::getConfMergedList { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/dsn_invalid_port.env"
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt.ext"
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"

  HOME="${BATS_TMP_DIR}/home" run Profiles::getConfMergedList "dsn" "env"
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/expectedDsnList.txt")"
}

function Profiles::getConfMergedListCustomIndent { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/dsn_invalid_port.env"
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt.ext"
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"

  HOME="${BATS_TMP_DIR}/home" run Profiles::getConfMergedList "dsn" "env" "* "
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/expectedDsnListCustomIndent.txt")"
}
