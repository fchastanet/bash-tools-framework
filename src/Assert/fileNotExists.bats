#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/fileNotExists.sh
source "${srcDir}/Assert/fileNotExists.sh"

teardown() {
  unstub_all
  rm -f "${BATS_TEST_TMPDIR}/myFile" || true
}

function Assert::fileNotExists::exists { #@test
  touch "${BATS_TEST_TMPDIR}/myFile"
  run Assert::fileNotExists "${BATS_TEST_TMPDIR}/myFile"
  assert_failure 1
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Checking file ${BATS_TEST_TMPDIR}/myFile does not exist"
  assert_line --index 1 --partial "ERROR   - file ${BATS_TEST_TMPDIR}/myFile still exists"
}

function Assert::fileNotExists::notExists { #@test
  run Assert::fileNotExists fileNotFound
  assert_success
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Checking file fileNotFound does not exist"
}
