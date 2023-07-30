#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Framework/run.sh
source "${srcDir}/Framework/run.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
}

teardown() {
  unstub_all
}

function Framework::run::status0 { #@test
  # date needed to compute duration
  stub date \
    '* : echo 1609970133' \
    '* : echo 1609970134'

  Framework::run echo 'hello' 2>"${BATS_TEST_TMPDIR}/error"
  # shellcheck disable=SC2154
  [[ "${bash_framework_status}" -eq 0 ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_duration}" = "1" ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_output}" = "hello" ]]
  [[ "$(cat "${BATS_TEST_TMPDIR}/error")" = "" ]]
}

function Framework::run::status1 { #@test
  # date needed to compute duration
  stub date \
    '* : echo 1609970133' \
    '* : echo 1609970134'

  Framework::run cat 'unknownFile' 2>"${BATS_TEST_TMPDIR}/error"

  # shellcheck disable=SC2154
  [[ "${bash_framework_status}" -eq 1 ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_duration}" = "1" ]]
  # shellcheck disable=SC2154
  [[ "${bash_framework_output}" = "" ]]
  run cat "${BATS_TEST_TMPDIR}/error"
  assert_output "cat: unknownFile: No such file or directory"
}
