#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/fileNotExecutable.sh
source "${srcDir}/Assert/fileNotExecutable.sh"

teardown() {
  unstub_all
  unset -f Assert::fileExists || true
  rm -f "${BATS_TEST_TMPDIR}/myFile" || true
}

function Assert::fileNotExecutable::notExists { #@test
  Assert::fileExists() {
    return 1
  }
  run Assert::fileNotExecutable "fileNotFound" "root" "root"
  assert_failure 1
  assert_output ""
}

function Assert::fileNotExecutable::notExecutable { #@test
  local file="${BATS_TEST_TMPDIR}/myFile"
  touch "${file}"
  chmod -x "${file}"
  Assert::fileExists() {
    return 0
  }
  run Assert::fileNotExecutable "${file}" "$(id -un)" "$(id -gn)"
  assert_success
  assert_output ""
}

function Assert::fileNotExecutable::executable { #@test
  local file="${BATS_TEST_TMPDIR}/myFile"
  touch "${file}"
  chmod +x "${file}"
  Assert::fileExists() {
    return 0
  }
  run Assert::fileNotExecutable "${file}" "$(id -un)" "$(id -gn)"
  assert_failure 2
  assert_output --partial "file ${file} is expected to be not executable"
}
