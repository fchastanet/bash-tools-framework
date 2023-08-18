#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/removeEmptyLinesFromBeginning.sh
source "${BATS_TEST_DIRNAME}/removeEmptyLinesFromBeginning.sh"

function Filters::removeEmptyLinesFromBeginning::stdin { #@test
  echo -e "\n\nTEST\n\t" | {
    run Filters::removeEmptyLinesFromBeginning
    assert_success
    assert_output "$(echo -e "TEST\n\t")"
  }
}

function Filters::removeEmptyLinesFromBeginning::stdinEmpty { #@test
  echo -e "" | {
    run Filters::removeEmptyLinesFromBeginning
    assert_success
    assert_output ""
  }
}

function Filters::removeEmptyLinesFromBeginning::stdinMultipleEmptyLines { #@test
  echo -e "\n    \t\n        \t   \nnon empty line\n    \t \n    \n  " | {
    run Filters::removeEmptyLinesFromBeginning
    assert_success
    assert_output "$(echo -e "non empty line\n    \t \n    \n  ")"
  }
}

function Filters::removeEmptyLinesFromBeginning::directive { #@test
  run Filters::removeEmptyLinesFromBeginning "${BATS_TEST_DIRNAME}/testsData/directive.sh"
  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/directive.sh")"
}
