#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/dirNotExists.sh
source "${srcDir}/Assert/dirNotExists.sh"

teardown() {
  unstub_all
  rm -Rf "${BATS_TEST_TMPDIR}/myDir" || true
}

function Assert::dirNotExists::exists { #@test
  mkdir "${BATS_TEST_TMPDIR}/myDir"
  run Assert::dirNotExists "${BATS_TEST_TMPDIR}/myDir"
  assert_failure 1
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Checking directory ${BATS_TEST_TMPDIR}/myDir does not exist"
  assert_line --index 1 --partial "ERROR   - Directory ${BATS_TEST_TMPDIR}/myDir still exists"
}

function Assert::dirNotExists::notExists { #@test
  run Assert::dirNotExists directoryNotFound
  assert_success
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Checking directory directoryNotFound does not exist"
}
