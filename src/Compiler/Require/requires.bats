#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Require/__all.sh
source "${srcDir}/Compiler/Require/__all.sh"

function Compiler::Require::requires::invalidFile { #@test
  run Compiler::Require::requires 'invalidFile' 2>&1
  assert_failure 2
  assert_lines_count 1
  assert_line --index 0 "grep: invalidFile: No such file or directory"
}

function Compiler::Require::requires::noRequires { #@test
  run Compiler::Require::requires "${BATS_TEST_DIRNAME}/testsData/binaryFile.require.noRequire" 2>&1
  assert_success
  assert_output ""
}

function Compiler::Require::requires::OneRequireFunctionInvalid { #@test
  run Compiler::Require::requires "${BATS_TEST_DIRNAME}/testsData/binaryFile.require.invalid" 2>&1
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Requirement 'Namespace::François' is not a valid bash framework function name"
}

function Compiler::Require::requires::OneRequireFunctionValid { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  export _COMPILE_FILE_ARGUMENTS
  run Compiler::Require::requires "${BATS_TEST_DIRNAME}/testsData/binaryFile.require.valid" 2>&1
  assert_success
  assert_lines_count 1
  assert_output "Namespace::requireSomething"
}

function Compiler::Require::requires::MultipleRequireFunctionValidMissingSrcDir { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  export _COMPILE_FILE_ARGUMENTS
  run Compiler::Require::requires "${BATS_TEST_DIRNAME}/testsData/binaryFile.require.multiple" 2>&1
  assert_failure 1
  assert_lines_count 1
  assert_line --index 0 --partial "ERROR   - Require function 'Linux::requireSudoCommand' cannot be found in any src dirs: ${BATS_TEST_DIRNAME}/testsData"
}

function Compiler::Require::requires::MultipleRequireFunctionValidCompileOK { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
    --src-dir "${srcDir}"
  )
  export _COMPILE_FILE_ARGUMENTS
  run Compiler::Require::requires "${BATS_TEST_DIRNAME}/testsData/binaryFile.require.multiple" 2>&1
  assert_success
  assert_lines_count 4
  assert_line --index 0 "Linux::requireSudoCommand"
  assert_line --index 1 "Linux::requireUbuntu"
  assert_line --index 2 "Log::requireLoad"
  assert_line --index 3 "Env::requireLoad"
}
