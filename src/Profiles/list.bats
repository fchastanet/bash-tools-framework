#!/usr/bin/env bash

FRAMEWORK_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
vendorDir="${FRAMEWORK_DIR}/vendor"
srcDir="${FRAMEWORK_DIR}/src"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Profiles/list.sh
source "${srcDir}/Profiles/list.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

teardown() {
  unstub_all
}

function Profiles::listPrefixProfileExtSh { #@test

  run Profiles::list "${BATS_TEST_DIRNAME}/testsData/dataGetList" "profile-" ".sh"
  assert_success
  # shellcheck disable=SC2154
  [[ "${#lines[@]}" = "2" ]]
  assert_line --index 0 "       - 1"
  assert_line --index 1 "       - 2"
}

function Profiles::listDirectories { #@test
  run Profiles::list "${BATS_TEST_DIRNAME}/testsData/dirGetList" "" "" "-mindepth 1 -type d" "*"
  assert_success
  [[ "${#lines[@]}" = "2" ]]
  assert_line --index 0 "*profile1"
  assert_line --index 1 "*profile2"
}

function Profiles::listDsnDashPrefix { #@test
  run Profiles::list "${BATS_TEST_DIRNAME}/testsData/dataGetList" "" ".dsn" "-type f" "-"
  assert_success
  [[ "${#lines[@]}" = "1" ]]
  assert_line --index 0 "-hello"
}

function Profiles::listUnknownDir { #@test
  run Profiles::list "${BATS_TEST_DIRNAME}/unknown" "dsn" "*"
  assert_failure 1
  assert_output --partial "Directory ${BATS_TEST_DIRNAME}/unknown does not exist"
}

function Profiles::listEmptyResult { #@test
  run Profiles::list "${BATS_TEST_DIRNAME}/testsData/dataGetList" "unknown" "*"
  assert_success 1
  assert_output ""
}
