#!/usr/bin/env bash

ROOT_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
vendorDir="${ROOT_DIR}/vendor"
srcDir="${ROOT_DIR}/src"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Framework/run.sh
source "${srcDir}/Framework/run.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
}

teardown() {
  unstub_all
  rm -Rf "${BATS_TMP_DIR}" || true
}

function Framework::run::status0 { #@test
  # date needed to compute duration
  stub date \
    '* : echo 1609970133' \
    '* : echo 1609970134'

  Framework::run echo 'hello' 2>"${BATS_TMP_DIR}/error"
  # shellcheck disable=SC2154
  [[ "${bash_framework_status}" -eq 0 ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_duration}" = "1" ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_output}" = "hello" ]]
  [[ "$(cat "${BATS_TMP_DIR}/error")" = "" ]]
}

function Framework::run::status1 { #@test
  # date needed to compute duration
  stub date \
    '* : echo 1609970133' \
    '* : echo 1609970134'

  Framework::run cat 'unknownFile' 2>"${BATS_TMP_DIR}/error"

  # shellcheck disable=SC2154
  [[ "${bash_framework_status}" -eq 1 ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_duration}" = "1" ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_output}" = "" ]]
  run cat "${BATS_TMP_DIR}/error"
  assert_output "cat: unknownFile: No such file or directory"
}
