#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=src/Filters/removeExternalQuotes.sh
source "${BATS_TEST_DIRNAME}/removeExternalQuotes.sh"

function Filters::removeExternalQuotes::double { #@test
  echo '"TEST"' | {
    run Filters::removeExternalQuotes
    assert_output "TEST"
  }
}

function Filters::removeExternalQuotes::single { #@test
  echo "'TEST'" | {
    run Filters::removeExternalQuotes
    assert_output "TEST"
  }
}

function Filters::removeExternalQuotes::notInsideDouble { #@test
  echo 'TEST"TEST' | {
    run Filters::removeExternalQuotes
    assert_output 'TEST"TEST'
  }
}

function Filters::removeExternalQuotes::notInsideSingle { #@test
  echo "TEST'TEST" | {
    run Filters::removeExternalQuotes
    assert_output "TEST'TEST"
  }
}
