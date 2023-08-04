#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

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

function Assert::bashFrameworkFunction::noMatchAccents { #@test
  run Assert::bashFrameworkFunction "Log::fatal::François"
  assert_failure
  assert_output ""
}

function Assert::bashFrameworkFunction::validSimple { #@test
  run Assert::bashFrameworkFunction "Log::fatal"
  assert_success
  assert_output ""
}

function Assert::bashFrameworkFunction::validMultiple { #@test
  run Assert::bashFrameworkFunction "Namespace1::Namespace2::function"
  assert_success
  assert_output ""
}

function Assert::bashFrameworkFunction::validWithPrefix { #@test
  PREFIX="sudo::" run Assert::bashFrameworkFunction "sudo::Namespace1::Namespace2::function"
  assert_success
  assert_output ""
}
