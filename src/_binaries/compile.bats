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
  local binDir="${FRAMEWORK_ROOT_DIR}/bin"
  local -a params=(
    # srcFile     : file that needs to be compiled
    "${BATS_TEST_DIRNAME}/testsData/bin/$1"
    # templateDir : directory from which bash-tpl templates will be searched
    --template-dir "${BATS_TEST_DIRNAME}/testsData/templates"
    # binDir      : fallback bin directory in case BIN_FILE has not been provided
    --bin-dir "${BATS_TEST_TMPDIR}"
    # rootDir     : directory used to compute src file relative path
    --root-dir "${FRAMEWORK_ROOT_DIR}"
    # srcDirs : (optional) you can provide multiple directories
    --src-dir "${BATS_TEST_DIRNAME}/testsData/src"
  )
  run "${binDir}/compile" "${params[@]}"
}

function compile::Simple { #@test
  run compile "simpleBinary.sh" 2>&1
  assert_output ""
  assert_success
  [[ -f "${BATS_TEST_TMPDIR}/simpleBinary" ]]
  [[ -x "${BATS_TEST_TMPDIR}/simpleBinary" ]]
  diff "${BATS_TEST_DIRNAME}/testsData/expectedBin/simpleBinary" "${BATS_TEST_TMPDIR}/simpleBinary"
}

function compile::var { #@test
  run compile "var.sh"
  assert_success
  [[ -f "${BATS_TEST_TMPDIR}/var" ]]
  [[ -x "${BATS_TEST_TMPDIR}/var" ]]
  diff "${BATS_TEST_DIRNAME}/testsData/expectedBin/var" "${BATS_TEST_TMPDIR}/var"
}

function compile::IncludeSimpleFile { #@test
  run compile "simpleBinary.sh"
  assert_success
  [[ -f "${BATS_TEST_TMPDIR}/simpleBinary" ]]
  [[ -x "${BATS_TEST_TMPDIR}/simpleBinary" ]]
  diff "${BATS_TEST_DIRNAME}/testsData/expectedBin/simpleBinary" "${BATS_TEST_TMPDIR}/simpleBinary"
}

function compile::embed { #@test
  run compile "embed.sh" 2>&1
  assert_success
  assert_output ""
  [[ -f "${BATS_TEST_TMPDIR}/embedBinary" ]]
  [[ -x "${BATS_TEST_TMPDIR}/embedBinary" ]]
  run "${BATS_TEST_TMPDIR}/embedBinary" 2>&1
  assert_lines_count 4
  assert_line --index 0 '----------------------------------------------------------------------------------------------------'
  assert_line --index 1 'embedFile1'
  assert_line --index 2 'embedFile1'
  assert_line --index 3 'embedFile2'

}
