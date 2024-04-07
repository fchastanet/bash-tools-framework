#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Framework/createTempFile.sh
source "${srcDir}/Framework/createTempFile.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
}

teardown() {
  unstub_all
}

function Framework::createTempFile::noName { #@test
  TMPDIR="${BATS_TEST_TMPDIR}" run Framework::createTempFile
  local regexp="^${BATS_TEST_TMPDIR}/\.[A-Za-z0-9]+\$"
  [[ "${output}" =~ ${regexp} ]]
}

function Framework::createTempFile::withName { #@test
  TMPDIR="${BATS_TEST_TMPDIR}" run Framework::createTempFile 'name'
  local regexp="^${BATS_TEST_TMPDIR}/name\.[A-Za-z0-9]+\$"
  [[ "${output}" =~ ${regexp} ]]
}
