#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/fileExecutable.sh
source "${srcDir}/Assert/fileExecutable.sh"

teardown() {
  unstub_all
  unset -f Assert::fileExists || true
  rm -f "${BATS_TEST_TMPDIR}/myFile" || true
}

function Assert::fileExecutable::notExists { #@test
  Assert::fileExists() {
    return 1
  }
  run Assert::fileExecutable "fileNotFound" "root" "root"
  assert_failure
  assert_output ""
}

function Assert::fileExecutable::notExecutable { #@test
  local file="${BATS_TEST_TMPDIR}/myFile"
  touch "${file}"
  chmod -x "${file}"
  Assert::fileExists() {
    return 0
  }
  run Assert::fileExecutable "${file}" "$(id -un)" "$(id -gn)"
  assert_failure 1
  assert_output --partial "file ${file} is expected to be executable"
}

function Assert::fileExecutable::executable { #@test
  local file="${BATS_TEST_TMPDIR}/myFile"
  touch "${file}"
  chmod +x "${file}"
  Assert::fileExists() {
    return 0
  }
  run Assert::fileExecutable "${file}" "$(id -un)" "$(id -gn)"
  assert_success
  assert_output ""
}
