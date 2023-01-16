#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Profiles/loadProfile.sh
source "${srcDir}/Profiles/loadProfile.sh"

teardown() {
  unstub_all
}

function Profiles::loadProfileOK { #@test
  run Profiles::loadProfile \
    "${BATS_TEST_DIRNAME}/testsData" "${BATS_TEST_DIRNAME}/testsData" "test1"

  assert_success
  # shellcheck disable=SC2154
  [[ "${#lines[@]}" = "2" ]]
  assert_line --index 0 --partial "INFO    - Loading profile '${BATS_TEST_DIRNAME}/testsData/profile.test1.sh'"
  assert_line --index 1 "Install1 Install2 Install4"
}

function Profiles::loadProfileDuplicates { #@test
  run Profiles::loadProfile \
    "${BATS_TEST_DIRNAME}/testsData" "${BATS_TEST_DIRNAME}/testsData" "test2Duplicates"

  assert_success
  [[ "${#lines[@]}" = "2" ]]
  assert_line --index 0 --partial "INFO    - Loading profile '${BATS_TEST_DIRNAME}/testsData/profile.test2Duplicates.sh'"
  assert_line --index 1 "Install4 Install1 Install2"
}

function Profiles::loadProfileUnknown { #@test
  run Profiles::loadProfile \
    "${BATS_TEST_DIRNAME}/testsData" "${BATS_TEST_DIRNAME}/testsData" "unknown"

  assert_failure 1
  # shellcheck disable=SC2154
  [[ "${#lines[@]}" = "2" ]]
  assert_line --index 0 --partial "INFO    - Loading profile '${BATS_TEST_DIRNAME}/testsData/profile.unknown.sh'"
  assert_line --index 1 --partial "profile profile.unknown.sh not found in '${BATS_TEST_DIRNAME}/testsData'"
}
