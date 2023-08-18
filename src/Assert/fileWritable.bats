#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/fileWritable.sh
source "${srcDir}/Assert/fileWritable.sh"

teardown() {
  unstub_all
  unset -f Assert::validPath
  rm -f "${BATS_TEST_TMPDIR}/myFile" || true
  rm -Rf "${BATS_TEST_TMPDIR}/myDir" || true
}

function Assert::fileWritable::invalidPath { #@test
  Assert::validPath() {
    return 1
  }
  run Assert::fileWritable "fileNotFound"
  assert_failure 1
  assert_output ""
}

function Assert::fileWritable::validPathDirNotWritable { #@test
  local dir="${BATS_TEST_TMPDIR}/myDir"
  mkdir -p "${dir}"
  chmod 444 "${dir}"
  local file="${dir}/myFile"
  Assert::validPath() {
    return 0
  }
  run Assert::fileWritable "${file}"
  assert_failure 2
  assert_output ""
}

function Assert::fileWritable::fileExistsButNotWritable { #@test
  local dir="${BATS_TEST_TMPDIR}/myDir"
  mkdir -p "${dir}"
  local file="${dir}/myFile"
  touch "${file}"
  chmod 444 "${file}"

  Assert::validPath() {
    return 0
  }
  run Assert::fileWritable "${file}"
  assert_failure 3
  assert_output ""
}

function Assert::fileWritable::valid { #@test
  local dir="${BATS_TEST_TMPDIR}/myDir"
  mkdir -p "${dir}"
  local file="${dir}/myFile"
  Assert::validPath() {
    return 0
  }
  run Assert::fileWritable "${file}"
  assert_success
  assert_output ""
}
