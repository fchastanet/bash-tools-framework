#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=src/Filters/toLowerCase.sh
source "${BATS_TEST_DIRNAME}/toLowerCase.sh"

function Filters::toLowerCase { #@test
  echo "TEST" | {
    run Filters::toLowerCase
    assert_output "test"
  }
}
