#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Conf/getMergedList.sh
source "${srcDir}/Conf/getMergedList.sh"
# shellcheck source=/src/Conf/list.sh
source "${srcDir}/Conf/list.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  mkdir -p "${BATS_TEST_TMPDIR}/home/.bash-tools/dsn"
  cp "${BATS_TEST_DIRNAME}/testsData/dsn/"* "${BATS_TEST_TMPDIR}/home/.bash-tools/dsn"
  export HOME"=${BATS_TEST_TMPDIR}/home"
}

teardown() {
  unstub_all
}

function Conf::getMergedList { #@test
  touch "${BATS_TEST_TMPDIR}/home/.bash-tools/dsn/dsn_invalid_port.env"
  touch "${BATS_TEST_TMPDIR}/home/.bash-tools/dsn/otherInvalidExt.ext"
  touch "${BATS_TEST_TMPDIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"

  HOME="${BATS_TEST_TMPDIR}/home" run Conf::getMergedList "dsn" "env"
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/expectedDsnList.txt")"
}

function Conf::getMergedListCustomIndent { #@test
  touch "${BATS_TEST_TMPDIR}/home/.bash-tools/dsn/dsn_invalid_port.env"
  touch "${BATS_TEST_TMPDIR}/home/.bash-tools/dsn/otherInvalidExt.ext"
  touch "${BATS_TEST_TMPDIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"

  HOME="${BATS_TEST_TMPDIR}/home" run Conf::getMergedList "dsn" "env" "* "
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/expectedDsnListCustomIndent.txt")"
}
