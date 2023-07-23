#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/bashFrameworkFunctions.sh
source "${BATS_TEST_DIRNAME}/bashFrameworkFunctions.sh"
# shellcheck source=src/Filters/commentLines.sh
source "${BATS_TEST_DIRNAME}/commentLines.sh"

function Filters::bashFrameworkFunctions::noMatch { #@test
  echo "TEST" | {
    run Filters::bashFrameworkFunctions
    assert_success
    assert_output ""
  }
}

function Filters::bashFrameworkFunctions::noMatch2 { #@test
  echo "Log:fatal" | {
    run Filters::bashFrameworkFunctions
    assert_success
    assert_output ""
  }
}

function Filters::bashFrameworkFunctions::noMatchComments1 { #@test
  local status=0
  local result=""
  result=$(echo "# Log::fatal" | Filters::commentLines | Filters::bashFrameworkFunctions) || status=$?
  [[ ${status} -eq 0 ]]
  [[ -z "${result}" ]]
}

function Filters::bashFrameworkFunctions::noMatchComments2 { #@test
  local status=0
  local result=""
  result=$(echo -e "  \t # Log::fatal" | Filters::commentLines | Filters::bashFrameworkFunctions) || status=$?
  [[ ${status} -eq 0 ]]
  [[ -z "${result}" ]]
}

function Filters::bashFrameworkFunctions::noMatchComments3 { #@test
  local status=0
  Filters::commentLines "${BATS_TEST_DIRNAME}/testsData/bashFrameworkFunctions.txt" |
    Filters::bashFrameworkFunctions \
      >"${BATS_RUN_TMPDIR}/bashFrameworkFunctions.result.txt" || status=$?
  [[ ${status} -eq 0 ]]
  diff \
    "${BATS_TEST_DIRNAME}/testsData/bashFrameworkFunctions.expected.txt" \
    "${BATS_RUN_TMPDIR}/bashFrameworkFunctions.result.txt"
}

function Filters::bashFrameworkFunctions::fromFile { #@test
  run Filters::bashFrameworkFunctions "${BATS_TEST_DIRNAME}/bashFrameworkFunctions.sh"
  assert_success
  assert_output "Filters::bashFrameworkFunctions"
}

function Filters::bashFrameworkFunctions::operator { #@test
  echo "(Log::fatal)" | {
    run Filters::bashFrameworkFunctions
    assert_success
    assert_output "Log::fatal"
  }
}

function Filters::bashFrameworkFunction::simple { #@test
  echo "Log::fatal" | {
    run Filters::bashFrameworkFunctions
    assert_success
    assert_output "Log::fatal"
  }
}

function Filters::bashFrameworkFunction::multiple { #@test
  echo "Namespace1::Namespace2::function" | {
    run Filters::bashFrameworkFunctions
    assert_success
    assert_output "Namespace1::Namespace2::function"
  }
}

function Filters::bashFrameworkFunction::withPrefix { #@test
  echo "sudo::Namespace1::Namespace2::function" | {
    PREFIX="sudo::" run Filters::bashFrameworkFunctions
    assert_success
    assert_output "sudo::Namespace1::Namespace2::function"
  }
}
