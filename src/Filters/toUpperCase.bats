#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/toUpperCase.sh
source "${BATS_TEST_DIRNAME}/toUpperCase.sh"

function Filters::toUpperCase::stdin { #@test
  echo "test" | {
    run Filters::toUpperCase
    assert_output "TEST"
  }
}

function Filters::toUpperCase::arg { #@test
  run Filters::toUpperCase "test"
  assert_output "TEST"
}

function Filters::toUpperCase::noMatch { #@test
  run Filters::toUpperCase ""
  assert_output ""
}
