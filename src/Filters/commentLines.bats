#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/commentLines.sh
source "${BATS_TEST_DIRNAME}/commentLines.sh"

function Filters::commentLines::singleLine { #@test
  echo "TEST" | {
    run Filters::commentLines
    assert_success
    assert_output "TEST"
  }
}

function Filters::commentLines::fromFile { #@test
  run Filters::commentLines "${BATS_TEST_DIRNAME}/testsData/commentLines.txt"
  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/commentLines.expected.txt")"
}

function Filters::commentLines::fromFile::doubleSlash { #@test
  commentLinePrefix='[/][/]' run Filters::commentLines "${BATS_TEST_DIRNAME}/testsData/commentLines.doubleSlash.txt"
  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/commentLines.doubleSlash.expected.txt")"
}

function Filters::commentLines::noMatch { #@test
  run Filters::commentLines "${BATS_TEST_DIRNAME}/testsData/commentLinesNoMatch.txt"
  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/commentLinesNoMatch.expected.txt")"
}
