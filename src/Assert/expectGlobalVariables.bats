#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/expectGlobalVariables.sh
source "${srcDir}/Assert/expectGlobalVariables.sh"

teardown() {
  unstub_all
}

function Assert::expectGlobalVariables::varNotDefined { #@test
  run Assert::expectGlobalVariables NOT_EXISTING_VAR
  assert_failure 1
  assert_output --partial "FATAL   - Variable NOT_EXISTING_VAR is unset"
}

function Assert::expectGlobalVariables::1varNotDefined { #@test
  export EXISTING_VAR=1
  run Assert::expectGlobalVariables EXISTING_VAR NOT_EXISTING_VAR
  assert_failure 1
  assert_output --partial "FATAL   - Variable NOT_EXISTING_VAR is unset"
}

function Assert::expectGlobalVariables::1varDefined { #@test
  export EXISTING_VAR=1
  run Assert::expectGlobalVariables EXISTING_VAR
  assert_success
  assert_output ""
}

function Assert::expectGlobalVariables::2varsDefined { #@test
  export EXISTING_VAR=1
  export EXISTING_VAR2=1
  run Assert::expectGlobalVariables EXISTING_VAR EXISTING_VAR2
  assert_success
  assert_output ""
}
