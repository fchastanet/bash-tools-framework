#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/dirEmpty.sh
source "${srcDir}/Assert/dirEmpty.sh"

teardown() {
  unstub_all
  rm -Rf "${BATS_TEST_TMPDIR}/myDir" || true
}

function Assert::dirEmpty::notExists { #@test
  run Assert::dirEmpty "${BATS_TEST_TMPDIR}/myDir"
  assert_failure 1
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Checking directory ${BATS_TEST_TMPDIR}/myDir is empty"
  assert_line --index 1 --partial "ERROR   - Directory ${BATS_TEST_TMPDIR}/myDir does not exist"
}

function Assert::dirEmpty::isAFile { #@test
  touch "${BATS_TEST_TMPDIR}/myDir"
  run Assert::dirEmpty "${BATS_TEST_TMPDIR}/myDir"
  assert_failure 2
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Checking directory ${BATS_TEST_TMPDIR}/myDir is empty"
  assert_line --index 1 --partial "ERROR   - ${BATS_TEST_TMPDIR}/myDir is actually a file"
}

function Assert::dirEmpty::notEmptyWithoutPattern { #@test
  mkdir "${BATS_TEST_TMPDIR}/myDir"
  touch "${BATS_TEST_TMPDIR}/myDir/myFile"
  run Assert::dirEmpty "${BATS_TEST_TMPDIR}/myDir"
  assert_failure 3
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Checking directory ${BATS_TEST_TMPDIR}/myDir is empty"
  assert_line --index 1 --partial "ERROR   - Directory ${BATS_TEST_TMPDIR}/myDir is not considered as empty"
}

function Assert::dirEmpty::emptyWithoutPattern { #@test
  mkdir "${BATS_TEST_TMPDIR}/myDir"
  run Assert::dirEmpty "${BATS_TEST_TMPDIR}/myDir"
  assert_success
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Checking directory ${BATS_TEST_TMPDIR}/myDir is empty"
}

function Assert::dirEmpty::emptyWithPattern { #@test
  mkdir "${BATS_TEST_TMPDIR}/myDir"
  touch "${BATS_TEST_TMPDIR}/myDir/.gitkeep"
  run Assert::dirEmpty "${BATS_TEST_TMPDIR}/myDir" ".gitkeep"
  assert_success
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Checking directory ${BATS_TEST_TMPDIR}/myDir is empty"
}

function Assert::dirEmpty::empty2Patterns { #@test
  mkdir "${BATS_TEST_TMPDIR}/myDir"
  touch "${BATS_TEST_TMPDIR}/myDir/.gitkeep"
  touch "${BATS_TEST_TMPDIR}/myDir/README.md"
  run Assert::dirEmpty "${BATS_TEST_TMPDIR}/myDir" ".gitkeep|README.md"
  assert_success
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Checking directory ${BATS_TEST_TMPDIR}/myDir is empty"
}

function Assert::dirEmpty::emptyWithPatternButFileMatchingPatternNotThere { #@test
  mkdir "${BATS_TEST_TMPDIR}/myDir"
  run Assert::dirEmpty "${BATS_TEST_TMPDIR}/myDir" ".gitkeep"
  assert_success
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Checking directory ${BATS_TEST_TMPDIR}/myDir is empty"
}

function Assert::dirEmpty::notEmptyWithPatternButFileMatchingPatternNotThere { #@test
  mkdir "${BATS_TEST_TMPDIR}/myDir"
  touch "${BATS_TEST_TMPDIR}/myDir/file"
  run Assert::dirEmpty "${BATS_TEST_TMPDIR}/myDir" ".gitkeep"
  assert_failure 3
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Checking directory ${BATS_TEST_TMPDIR}/myDir is empty"
  assert_line --index 1 --partial "ERROR   - Directory ${BATS_TEST_TMPDIR}/myDir is not considered as empty"
}
