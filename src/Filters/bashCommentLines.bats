#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=src/Filters/bashCommentLines.sh
source "${BATS_TEST_DIRNAME}/bashCommentLines.sh"

function Filters::bashCommentLines::singleLine { #@test
  echo "TEST" | {
    run Filters::bashCommentLines
    assert_success
    assert_output "TEST"
  }
}

function Filters::bashCommentLines::fromFile { #@test
  run Filters::bashCommentLines "${BATS_TEST_DIRNAME}/testsData/bashCommentLines.txt" \
    >"${BATS_RUN_TMPDIR}/bashCommentLines.result.txt"
  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/bashCommentLines.expected.txt")"
}
