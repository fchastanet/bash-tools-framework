#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=src/Filters/bashFrameworkFunctions.sh
source "${BATS_TEST_DIRNAME}/bashFrameworkFunctions.sh"

function Filters::bashFrameworkFunctionsNoMatch { #@test
  echo "TEST" | {
    run Filters::bashFrameworkFunctions
    assert_failure
    assert_output ""
  }
}

function Filters::bashFrameworkFunctionsNoMatch2 { #@test
  echo "Log:fatal" | {
    run Filters::bashFrameworkFunctions
    assert_failure
    assert_output ""
  }
}

function Filters::bashFrameworkFunctionsFromFile { #@test
  run Filters::bashFrameworkFunctions "${BATS_TEST_DIRNAME}/bashFrameworkFunctions.sh"
  assert_success
  assert_output "Filters::bashFrameworkFunctions"
}

function Filters::bashFrameworkFunctionsOperator { #@test
  echo "(Log::fatal)" | {
    run Filters::bashFrameworkFunctions
    assert_success
    assert_output "Log::fatal"
  }
}

function Filters::bashFrameworkFunctionSimple { #@test
  echo "Log::fatal" | {
    run Filters::bashFrameworkFunctions
    assert_success
    assert_output "Log::fatal"
  }
}

function Filters::bashFrameworkFunctionMultiple { #@test
  echo "Namespace1::Namespace2::function" | {
    run Filters::bashFrameworkFunctions
    assert_success
    assert_output "Namespace1::Namespace2::function"
  }
}
