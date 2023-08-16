#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/Implement/assertInterface.sh
source "${srcDir}/Compiler/Implement/assertInterface.sh"
# shellcheck source=/src/Compiler/Implement/interfaceFunctions.sh
source "${srcDir}/Compiler/Implement/interfaceFunctions.sh"
# shellcheck source=/src/Assert/bashFrameworkFunction.sh
source "${srcDir}/Assert/bashFrameworkFunction.sh"
# shellcheck source=/src/Compiler/findFunctionInSrcDirs.sh
source "${srcDir}/Compiler/findFunctionInSrcDirs.sh"
# shellcheck source=/src/Compiler/Embed/getSrcDirsFromOptions.sh
source "${srcDir}/Compiler/Embed/getSrcDirsFromOptions.sh"
# shellcheck source=/src/Assert/posixFunctionName.sh
source "${srcDir}/Assert/posixFunctionName.sh"

teardown() {
  rm -f "${BATS_TEST_TMPDIR}/symbolicLink" "${BATS_TEST_TMPDIR}/result" || true
}

declare -ax _COMPILE_FILE_ARGUMENTS=(
  --src-dir "${srcDir}"
)

function Compiler::Implement::assertInterface::Empty { #@test
  run Compiler::Implement::assertInterface ""
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Interface '${interface}' is not a valid bash framework function name"
}

function Compiler::Implement::assertInterface::InvalidBashFrameworkFunction { #@test
  run Compiler::Implement::assertInterface "Implemented::data::François"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Interface 'Implemented::data::François' is not a valid bash framework function name"
}

function Compiler::Implement::assertInterface::BashFrameworkFunctionNotFound { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}"
  )
  local status=0
  Compiler::Implement::assertInterface "Compiler::Implement::assertInterface" "${BATS_TEST_DIRNAME}" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "2" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Interface 'Compiler::Implement::assertInterface' cannot be found in any src dirs: ${BATS_TEST_DIRNAME}"
}

function Compiler::Implement::assertInterface::BashFrameworkFunctionErrorDuringCall { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${srcDir}"
  )
  local status=0
  Compiler::Implement::assertInterface "Compiler::Implement::assertInterface" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "3" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 --partial "ERROR   - Interface '' is not a valid bash framework function name"
  assert_line --index 1 --partial "ERROR   - Calling interface 'Compiler::Implement::assertInterface' has generated an error"
}

function Compiler::Implement::assertInterface::InterfaceEmptyList { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  local status=0
  Compiler::Implement::assertInterface "Namespace::interfaceEmptyList" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "4" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 --partial "ERROR   - Calling interface 'Namespace::interfaceEmptyList' resulted to an empty functions list"
}

function Compiler::Implement::assertInterface::InterfaceInvalidList { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  local status=0
  Compiler::Implement::assertInterface "Namespace::interfaceInvalidList" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "5" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 --partial "ERROR   - the function 'invalid::Function' of interface 'Namespace::interfaceInvalidList' has an invalid posix name"
}

function Compiler::Implement::assertInterface::validInterface { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  local status=0
  Compiler::Implement::assertInterface "Namespace::interfaceValidList" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}
