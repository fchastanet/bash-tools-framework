#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/trimEmptyLines.sh
source "${BATS_TEST_DIRNAME}/trimEmptyLines.sh"

function Filters::trimEmptyLines::stdin { #@test
  echo -e "\n\nTEST1\n\t\nTEST2\n\t" | {
    run Filters::trimEmptyLines
    assert_success
    assert_output "$(echo -e "TEST1\n\t\nTEST2")"
  }
}

function Filters::trimEmptyLines::stdinEmpty { #@test
  echo -e "" | {
    run Filters::trimEmptyLines
    assert_success
    assert_output ""
  }
}

function Filters::trimEmptyLines::stdinMultipleEmptyLines { #@test
  echo -e "\n    \t\n        \t   \nnon empty line1\n    \t non empty line2\n    \n  " | {
    run Filters::trimEmptyLines
    assert_success
    assert_output "$(echo -e "non empty line1\n    \t non empty line2")"
  }
}

function Filters::trimEmptyLines::file { #@test
  echo -e "\n\nTEST1\n\t\nTEST2\n\t" >"${BATS_TEST_TMPDIR}/file"
  run Filters::trimEmptyLines "${BATS_TEST_TMPDIR}/file"
  assert_success
  assert_output "$(echo -e "TEST1\n\t\nTEST2")"
}

function Filters::trimEmptyLines::directive { #@test
  run Filters::trimEmptyLines "${BATS_TEST_DIRNAME}/testsData/directive.sh"
  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/directive.sh")"
}
