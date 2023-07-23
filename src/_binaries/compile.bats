#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

setup() {
  TMPDIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR
}

teardown() {
  rm -Rf "${TMPDIR}" || true
}

function compile() {
  local binDir="${ROOT_DIR}/bin"
  local -a params=(
    # srcFile     : file that needs to be compiled
    "${BATS_TEST_DIRNAME}/testsData/bin/$1"
    # templateDir : directory from which bash-tpl templates will be searched
    --template-dir "${BATS_TEST_DIRNAME}/testsData/templates"
    # binDir      : fallback bin directory in case BIN_FILE has not been provided
    --bin-dir "${BATS_RUN_TMPDIR}"
    # rootDir     : directory used to compute src file relative path
    --root-dir "${ROOT_DIR}"
    # srcDirs : (optional) you can provide multiple directories
    --src-dir "${BATS_TEST_DIRNAME}/testsData/src"
  )
  run "${binDir}/compile" "${params[@]}"
}

function compile::Simple { #@test
  run compile "simpleBinary.sh"
  assert_success
  [[ -f "${BATS_RUN_TMPDIR}/simpleBinary" ]]
  [[ -x "${BATS_RUN_TMPDIR}/simpleBinary" ]]
  diff "${BATS_TEST_DIRNAME}/testsData/expectedBin/simpleBinary" "${BATS_RUN_TMPDIR}/simpleBinary"
}

function compile::Meta { #@test
  run compile "meta.sh"
  assert_success
  [[ -f "${BATS_RUN_TMPDIR}/meta" ]]
  [[ -x "${BATS_RUN_TMPDIR}/meta" ]]
  diff "${BATS_TEST_DIRNAME}/testsData/expectedBin/meta" "${BATS_RUN_TMPDIR}/meta"
}

function compile::IncludeSimpleFile { #@test
  run compile "simpleBinary.sh"
  assert_success
  [[ -f "${BATS_RUN_TMPDIR}/simpleBinary" ]]
  [[ -x "${BATS_RUN_TMPDIR}/simpleBinary" ]]
  diff "${BATS_TEST_DIRNAME}/testsData/expectedBin/simpleBinary" "${BATS_RUN_TMPDIR}/simpleBinary"
}
