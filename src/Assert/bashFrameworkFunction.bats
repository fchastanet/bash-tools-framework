#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=src/Assert/bashFrameworkFunction.sh
source "${BATS_TEST_DIRNAME}/bashFrameworkFunction.sh"

function Assert::bashFrameworkFunction::noMatch { #@test
  run Assert::bashFrameworkFunction "TEST"
  assert_failure
  assert_output ""
}

function Assert::bashFrameworkFunction::noMatch2 { #@test
  run Assert::bashFrameworkFunction "Log:fatal"
  assert_failure
  assert_output ""
}

function Assert::bashFrameworkFunction::noMatchComments1 { #@test
  run Assert::bashFrameworkFunction "# Log::fatal"
  assert_failure
  assert_output ""
}

function Assert::bashFrameworkFunction::noMatchComments2 { #@test
  run Assert::bashFrameworkFunction "  \t # Log::fatal"
  assert_failure
  assert_output ""
}

function Assert::bashFrameworkFunction::simple { #@test
  run Assert::bashFrameworkFunction "Log::fatal"
  assert_success
  assert_output ""
}

function Assert::bashFrameworkFunction::multiple { #@test
  run Assert::bashFrameworkFunction "Namespace1::Namespace2::function"
  assert_success
  assert_output ""
}

function Assert::bashFrameworkFunction::withPrefix { #@test
  PREFIX="sudo::" run Assert::bashFrameworkFunction "sudo::Namespace1::Namespace2::function"
  assert_success
  assert_output ""
}