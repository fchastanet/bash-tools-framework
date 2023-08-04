#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/removeEmptyLines.sh
source "${BATS_TEST_DIRNAME}/removeEmptyLines.sh"

function Filters::removeEmptyLines::stdin { #@test
  echo -e "\n\nTEST\n\t" | {
    run Filters::removeEmptyLines
    assert_success
    assert_output "TEST"
  }
}

function Filters::removeEmptyLines::stdinEmpty { #@test
  echo -e "" | {
    run Filters::removeEmptyLines
    assert_success
    assert_output ""
  }
}

function Filters::removeEmptyLines::directive { #@test
  run Filters::removeEmptyLines "${BATS_TEST_DIRNAME}/testsData/directive.sh"
  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/removeEmptyLines.directive.txt")"
}
