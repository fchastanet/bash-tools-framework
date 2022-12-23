#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=src/Filters/toUpperCase.sh
source "${BATS_TEST_DIRNAME}/toUpperCase.sh"

function Filters::toUpperCase { #@test
  echo "test" | {
    run Filters::toUpperCase
    assert_output "TEST"
  }
}
