#!/usr/bin/env bash

FRAMEWORK_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
vendorDir="${FRAMEWORK_DIR}/vendor"
srcDir="${FRAMEWORK_DIR}/src"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Assert/varExistsAndNotEmpty.sh
source "${srcDir}/Assert/varExistsAndNotEmpty.sh"
# shellcheck source=/src/Assert/validVariableName.sh
source "${srcDir}/Assert/validVariableName.sh"
# shellcheck source=/src/batsHeaders.sh
source "${srcDir}/batsHeaders.sh"

function Assert::varExistsAndNotEmpty_EmptyVariableName { #@test
  run Assert::varExistsAndNotEmpty ""
  assert_failure
  assert_output --partial "ERROR   -  - invalid variable name"
}

function Assert::varExistsAndNotEmpty_InvalidVariableName { #@test
  run Assert::varExistsAndNotEmpty "èHY"
  assert_failure
  assert_output --partial "ERROR   - èHY - invalid variable name"
}

function Assert::varExistsAndNotEmpty_DoesNotExists { #@test
  run Assert::varExistsAndNotEmpty "UNKNOWN_VARIABLE"
  assert_failure 1
  assert_output --partial "ERROR   - UNKNOWN_VARIABLE - not defined"
}

function Assert::varExistsAndNotEmpty_emptyVariable { #@test
  export KNOWN_VARIABLE_EMPTY=""
  run Assert::varExistsAndNotEmpty "KNOWN_VARIABLE_EMPTY"
  assert_failure 2
  assert_output --partial "ERROR   - KNOWN_VARIABLE_EMPTY - please provide a value"
}

function Assert::varExistsAndNotEmpty_nonEmptyVariable { #@test
  export KNOWN_VARIABLE="NonEmpty"
  run Assert::varExistsAndNotEmpty "KNOWN_VARIABLE"
  assert_success
  assert_output --partial ""
}
