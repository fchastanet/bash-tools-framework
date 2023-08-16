#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Implement/interfaces.sh
source "${srcDir}/Compiler/Implement/interfaces.sh"
# shellcheck source=src/Compiler/Implement/interfaceFunctions.sh
source "${srcDir}/Compiler/Implement/interfaceFunctions.sh"
# shellcheck source=src/Compiler/Implement/filter.sh
source "${srcDir}/Compiler/Implement/filter.sh"
# shellcheck source=src/Compiler/Implement/parse.sh
source "${srcDir}/Compiler/Implement/parse.sh"
# shellcheck source=src/Compiler/Implement/assertInterface.sh
source "${srcDir}/Compiler/Implement/assertInterface.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "${srcDir}/Filters/removeExternalQuotes.sh"
# shellcheck source=src/Assert/bashFrameworkFunction.sh
source "${srcDir}/Assert/bashFrameworkFunction.sh"
# shellcheck source=src/Assert/posixFunctionName.sh
source "${srcDir}/Assert/posixFunctionName.sh"
# shellcheck source=src/Compiler/Embed/getSrcDirsFromOptions.sh
source "${srcDir}/Compiler/Embed/getSrcDirsFromOptions.sh"
# shellcheck source=src/Compiler/findFunctionInSrcDirs.sh
source "${srcDir}/Compiler/findFunctionInSrcDirs.sh"

function Compiler::Implement::interfaces::invalidFile { #@test
  run Compiler::Implement::interfaces 'invalidFile' 2>&1
  assert_failure 2
  assert_lines_count 1
  assert_line --index 0 "grep: invalidFile: No such file or directory"
}

function Compiler::Implement::interfaces::interfaceFileNotFound { #@test
  run Compiler::Implement::interfaces "${BATS_TEST_DIRNAME}/testsData/interfacesTwiceSame.sh" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - Interface 'Namespace::interfaceValidList' cannot be found in any src dirs:"
}

function Compiler::Implement::interfaces::invalidBashFrameworkFunction { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  local status=0
  Compiler::Implement::interfaces \
    "${BATS_TEST_DIRNAME}/testsData/interfacesInvalidBashFrameworkFunction.sh" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 --partial $'ERROR   - Interface \'"${BATS_TEST_DIRNAME}/test\' is not a valid bash framework function name'
}

function Compiler::Implement::interfaces::twiceSameInterface { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  local status=0
  Compiler::Implement::interfaces \
    "${BATS_TEST_DIRNAME}/testsData/interfacesTwiceSame.sh" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output "Namespace::interfaceValidList"
}

function Compiler::Implement::interfaces::interfacesMismatchFunctionName { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  local status=0
  Compiler::Implement::interfaces \
    "${BATS_TEST_DIRNAME}/testsData/interfacesMismatchFunctionName.sh" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 3
  assert_line --index 0 --partial "Namespace::interfaceMismatchFunctionName: command not found"
  assert_line --index 1 --partial "ERROR   - Calling interface 'Namespace::interfaceMismatchFunctionName' has generated an error"
  assert_line --index 2 "Namespace::interfaceValidList"
}

function Compiler::Implement::interfaces::twoInterfaces { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  local status=0
  Compiler::Implement::interfaces \
    "${BATS_TEST_DIRNAME}/testsData/interfacesTwo.sh" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "Namespace::interfaceValidList"
  assert_line --index 1 "Namespace::interfaceValidList2"
}
