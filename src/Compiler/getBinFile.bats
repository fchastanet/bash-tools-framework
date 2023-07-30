#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/getBinFile.sh
source "${BATS_TEST_DIRNAME}/getBinFile.sh"
# shellcheck source=/src/Filters/directive.sh
source "${srcDir}/Filters/directive.sh"
# shellcheck source=/src/Filters/directiveValue.sh
source "${srcDir}/Filters/directiveValue.sh"
# shellcheck source=/src/Assert/validPath.sh
source "${srcDir}/Assert/validPath.sh"

function teardown() {
  rm -Rf "${BATS_TEST_TMPDIR:?}/bin" || true
}
function Compiler::getBinFile::oneOccurrence { #@test
  run Compiler::getBinFile "${BATS_TEST_DIRNAME}/testsData/binFile1.sh"
  assert_success
  assert_output "${BATS_TEST_TMPDIR}/bin/awkLint"
  [[ -d "${BATS_TEST_TMPDIR:?}/bin" ]]
}

function Compiler::getBinFile::twoOccurrences { #@test
  export BATS_TEST_TMPDIR
  # only first one is taken into account
  run Compiler::getBinFile "${BATS_TEST_DIRNAME}/testsData/binFile2.sh"
  assert_success
  assert_output "${BATS_TEST_TMPDIR}/bin/awkLint"
  [[ -d "${BATS_TEST_TMPDIR:?}/bin" ]]
}

function Compiler::getBinFile::zeroOccurrence { #@test
  export BATS_TEST_TMPDIR
  run Compiler::getBinFile "${BATS_TEST_DIRNAME}/testsData/meta1.sh" >&2
  assert_success
  assert_output --partial "SKIPPED - ${BATS_TEST_DIRNAME}/testsData/meta1.sh does not contains BIN_FILE directive"
  [[ ! -d "${BATS_TEST_TMPDIR:?}/bin" ]]
}

function Compiler::getBinFile::fileDoesNotExists { #@test
  export BATS_TEST_TMPDIR
  run Compiler::getBinFile "${BATS_TEST_DIRNAME}/testsData/binary1.sh" >&2
  assert_failure
  assert_output --partial "does not define a valid BIN_FILE value: '<% "
  [[ ! -d "${BATS_TEST_TMPDIR:?}/bin" ]]
}
