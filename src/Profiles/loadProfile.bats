#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Profiles/loadProfile.sh
source "${srcDir}/Profiles/loadProfile.sh"
# shellcheck source=/src/Assert/fileWritable.sh
source "${srcDir}/Assert/fileWritable.sh"
# shellcheck source=/src/Assert/validPath.sh
source "${srcDir}/Assert/validPath.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  logFile=""$(mktemp -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)""

  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=0
}

teardown() {
  unstub_all
  rm -f "${logFile}" || true
}

function Profiles::loadProfile::OK { #@test
  run Profiles::loadProfile \
    "${BATS_TEST_DIRNAME}/testsData" "test1"

  assert_success
  # shellcheck disable=SC2154
  assert_lines_count 4
  assert_line --index 0 --partial "INFO    - Loading profile '${BATS_TEST_DIRNAME}/testsData/profile.test1.sh'"
  assert_line --index 1 "Install1"
  assert_line --index 2 "Install2"
  assert_line --index 3 "Install4"
}

function Profiles::loadProfile::Duplicates { #@test
  run Profiles::loadProfile \
    "${BATS_TEST_DIRNAME}/testsData" "test2Duplicates"

  assert_success
  assert_lines_count 4
  assert_line --index 0 --partial "INFO    - Loading profile '${BATS_TEST_DIRNAME}/testsData/profile.test2Duplicates.sh'"
  assert_line --index 1 "Install4"
  assert_line --index 2 "Install1"
  assert_line --index 3 "Install2"
}

function Profiles::loadProfile::Unknown { #@test
  run Profiles::loadProfile \
    "${BATS_TEST_DIRNAME}/testsData" "unknown"

  assert_failure 2
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Loading profile '${BATS_TEST_DIRNAME}/testsData/profile.unknown.sh'"
  assert_line --index 1 --partial "profile profile.unknown.sh not found in '${BATS_TEST_DIRNAME}/testsData'"
}

function Profiles::loadProfile::MissingProfileArg { #@test
  run Profiles::loadProfile \
    "${BATS_TEST_DIRNAME}/testsData"

  assert_failure 1
  assert_lines_count 1
  assert_line --index 0 --partial "ERROR   - This method needs exactly 2 parameters"
}

function Profiles::loadProfile::MissingArgs { #@test
  run Profiles::loadProfile

  assert_failure 1
  assert_lines_count 1
  assert_line --index 0 --partial "ERROR   - This method needs exactly 2 parameters"
}
