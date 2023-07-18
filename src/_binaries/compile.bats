#!/usr/bin/env bash

testDir="$(cd "${BATS_TEST_DIRNAME}" && pwd -P)"
rootDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
vendorDir="${rootDir}/vendor"
binDir="${rootDir}/bin"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
}

teardown() {
  rm -Rf "${BATS_TMP_DIR}" || true
}

function compile() {
  local -a params=(
    # srcFile     : file that needs to be compiled
    "${testDir}/testsData/bin/$1"
    # templateDir : directory from which bash-tpl templates will be searched
    "${testDir}/testsData/templates"
    # binDir      : fallback bin directory in case BIN_FILE has not been provided
    "${BATS_TMP_DIR}"
    # rootDir     : directory used to compute src file relative path
    "${rootDir}"
    # srcDirs : (optional) you can provide multiple directories
    "${testDir}/testsData/src"
  )
  run "${binDir}/compile" "${params[@]}"
}

function compile::Simple { #@test
  run compile "simpleBinary.sh"
  assert_success
  [[ -f "${BATS_TMP_DIR}/simpleBinary" ]]
  [[ -x "${BATS_TMP_DIR}/simpleBinary" ]]
  diff "${BATS_TEST_DIRNAME}/testsData/expectedBin/simpleBinary" "${BATS_TMP_DIR}/simpleBinary"
}

function compile::Meta { #@test
  run compile "meta.sh"
  assert_success
  [[ -f "${BATS_TMP_DIR}/meta" ]]
  [[ -x "${BATS_TMP_DIR}/meta" ]]
  diff "${BATS_TEST_DIRNAME}/testsData/expectedBin/meta" "${BATS_TMP_DIR}/meta"
}

function compile::IncludeSimpleFile { #@test
  run compile "simpleBinary.sh"
  assert_success
  [[ -f "${BATS_TMP_DIR}/simpleBinary" ]]
  [[ -x "${BATS_TMP_DIR}/simpleBinary" ]]
  diff "${BATS_TEST_DIRNAME}/testsData/expectedBin/simpleBinary" "${BATS_TMP_DIR}/simpleBinary"
}
