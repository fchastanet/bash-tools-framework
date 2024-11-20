#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/symLinkValid.sh
source "${srcDir}/Assert/symLinkValid.sh"

teardown() {
  unstub_all
  rm -f "${BATS_TEST_TMPDIR}/myFile" "${BATS_TEST_TMPDIR}/link" || true
}

function Assert::symLinkValid::notExists { #@test
  run Assert::symLinkValid "fileNotFound"
  assert_failure 1
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Check fileNotFound is a valid symlink"
  assert_line --index 1 --partial "ERROR   - fileNotFound is not existing"
}

function Assert::symLinkValid::notALink { #@test
  local file="${BATS_TEST_TMPDIR}/myFile"
  touch "${file}"
  run Assert::symLinkValid "${file}"
  assert_failure 2
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Check ${BATS_TEST_TMPDIR}/myFile is a valid symlink"
  assert_line --index 1 --partial "ERROR   - ${BATS_TEST_TMPDIR}/myFile exists but is not a link"
}

function Assert::symLinkValid::brokenLink { #@test
  local file="${BATS_TEST_TMPDIR}/myFile"
  touch "${file}"
  ln -sf "${file}" "${BATS_TEST_TMPDIR}/link"
  rm "${file}"
  run Assert::symLinkValid "${BATS_TEST_TMPDIR}/link"
  assert_failure 3
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Check ${BATS_TEST_TMPDIR}/link is a valid symlink"
  assert_line --index 1 --partial "ERROR   - Broken link ${BATS_TEST_TMPDIR}/link"
}

function Assert::symLinkValid::valid { #@test
  local file="${BATS_TEST_TMPDIR}/myFile"
  touch "${file}"
  ln -sf "${file}" "${BATS_TEST_TMPDIR}/link"
  run Assert::symLinkValid "${BATS_TEST_TMPDIR}/link"
  assert_success
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Check ${BATS_TEST_TMPDIR}/link is a valid symlink"
}
