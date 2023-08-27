#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/fileExists.sh
source "${srcDir}/Assert/fileExists.sh"

teardown() {
  unstub_all
  rm -f "${BATS_TEST_TMPDIR}/myFile" || true
}

function Assert::fileExists::notExists { #@test
  run Assert::fileExists "fileNotFound" "root" "root"
  assert_failure 1
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Check fileNotFound exists with user root:root"
  assert_line --index 1 --partial "ERROR   - missing file fileNotFound"
}

function Assert::fileExists::notRightUser { #@test
  stub stat \
    "-c '%U' * : exit 1" \
    "-c '%G' * : echo 'groupKnown'"
  local file="${BATS_TEST_TMPDIR}/myFile"
  touch "${file}"
  run Assert::fileExists "${file}" "userUnknown" "groupKnown"
  assert_failure 2
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Check ${BATS_TEST_TMPDIR}/myFile exists with user userUnknown:groupKnown"
  assert_line --index 1 --partial "ERROR   - incorrect user ownership on file ${BATS_TEST_TMPDIR}/myFile"
}

function Assert::fileExists::notRightGroup { #@test
  stub stat \
    "-c '%U' * : echo 'userKnown'" \
    "-c '%G' * : exit 1"
  local file="${BATS_TEST_TMPDIR}/myFile"
  touch "${file}"
  run Assert::fileExists "${file}" "userKnown" "groupUnknown"
  assert_failure 3
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Check ${BATS_TEST_TMPDIR}/myFile exists with user userKnown:groupUnknown"
  assert_line --index 1 --partial "ERROR   - incorrect group ownership on file ${BATS_TEST_TMPDIR}/myFile"
}

function Assert::fileExists::valid { #@test
  stub stat \
    "-c '%U' * : echo 'userKnown'" \
    "-c '%G' * : echo 'groupKnown'"
  local file="${BATS_TEST_TMPDIR}/myFile"
  touch "${file}"
  run Assert::fileExists "${file}" "userKnown" "groupKnown"
  assert_success
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Check ${BATS_TEST_TMPDIR}/myFile exists with user userKnown:groupKnown"
}
