#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/toLowerCase.sh
source "${BATS_TEST_DIRNAME}/toLowerCase.sh"

function Filters::toLowerCase::stdin { #@test
  echo "TEST" | {
    run Filters::toLowerCase
    assert_output "test"
  }
}

function Filters::toLowerCase::arg { #@test
  run Filters::toLowerCase "TEST"
  assert_output "test"
}

function Filters::toLowerCase::noMatch { #@test
  run Filters::toLowerCase ""
  assert_output ""
}
