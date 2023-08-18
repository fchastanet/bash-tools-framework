#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/validVariableName.sh
source "${srcDir}/Assert/validVariableName.sh"

function Assert::validVariableName::invalid { #@test
  run Assert::validVariableName ""
  assert_failure 1
  assert_output ""
}

function Assert::validVariableName::noAccent { #@test
  run Assert::validVariableName "frégate"
  assert_failure 1
  assert_output ""
}

function Assert::validVariableName::noDash { #@test
  run Assert::validVariableName "extra-file"
  assert_failure 1
  assert_output ""
}

function Assert::validVariableName::noAt { #@test
  run Assert::validVariableName "my@variable"
  assert_failure 1
  assert_output ""
}

function Assert::validVariableName::noSpace { #@test
  run Assert::validVariableName "var files_count invalid"
  assert_failure 1
  assert_output ""
}

function Assert::validVariableName::invalidUppercase { #@test
  run Assert::validVariableName "FILEs_COUNT"
  assert_failure 1
  assert_output ""
}

function Assert::validVariableName::validUppercase { #@test
  run Assert::validVariableName "FILES_COUNT"
  assert_success
  assert_output ""
}

function Assert::validVariableName::validLowercase { #@test
  run Assert::validVariableName "files_count"
  assert_success
  assert_output ""
}
