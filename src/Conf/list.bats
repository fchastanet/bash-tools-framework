#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Conf/list.sh
source "${srcDir}/Conf/list.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

teardown() {
  unstub_all
}

function Conf::listPrefixProfileExtSh { #@test

  run Conf::list "${BATS_TEST_DIRNAME}/testsData/dataGetList" "profile-" ".sh"
  assert_success
  # shellcheck disable=SC2154
  assert_lines_count 2
  assert_line --index 0 "       - 1"
  assert_line --index 1 "       - 2"
}

function Conf::listDirectories { #@test
  run Conf::list "${BATS_TEST_DIRNAME}/testsData/dirGetList" "" "" "-mindepth 1 -type d" "*"
  assert_success
  assert_lines_count 2
  assert_line --index 0 "*profile1"
  assert_line --index 1 "*profile2"
}

function Conf::listDsnDashPrefix { #@test
  run Conf::list "${BATS_TEST_DIRNAME}/testsData/dataGetList" "" ".dsn" "-type f" "-"
  assert_success
  assert_lines_count 1
  assert_line --index 0 "-hello"
}

function Conf::listUnknownDir { #@test
  run Conf::list "${BATS_TEST_DIRNAME}/unknown" "dsn" "*"
  assert_failure 1
  assert_output --partial "Directory ${BATS_TEST_DIRNAME}/unknown does not exist"
}

function Conf::listEmptyResult { #@test
  run Conf::list "${BATS_TEST_DIRNAME}/testsData/dataGetList" "unknown" "*"
  assert_success 1
  assert_output ""
}
