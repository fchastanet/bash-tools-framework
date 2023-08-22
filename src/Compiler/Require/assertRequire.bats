#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/Require/assertRequire.sh
source "${srcDir}/Compiler/Require/assertRequire.sh"
# shellcheck source=/src/Assert/bashFrameworkFunction.sh
source "${srcDir}/Assert/bashFrameworkFunction.sh"
# shellcheck source=/src/Compiler/findFunctionInSrcDirs.sh
source "${srcDir}/Compiler/findFunctionInSrcDirs.sh"
# shellcheck source=/src/Compiler/Embed/getSrcDirsFromOptions.sh
source "${srcDir}/Compiler/Embed/getSrcDirsFromOptions.sh"

teardown() {
  rm -f "${BATS_TEST_TMPDIR}/symbolicLink" "${BATS_TEST_TMPDIR}/result" || true
}

declare -ax _COMPILE_FILE_ARGUMENTS=(
  --src-dir "${srcDir}"
)

function Compiler::Require::assertRequire::Empty { #@test
  run Compiler::Require::assertRequire ""
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Requirement '' is not a valid bash framework function name"
}

function Compiler::Require::assertRequire::InvalidBashFrameworkFunction { #@test
  run Compiler::Require::assertRequire "Implemented::data::François"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Requirement 'Implemented::data::François' is not a valid bash framework function name"
}

function Compiler::Require::assertRequire::InvalidRequireFunction { #@test
  run Compiler::Require::assertRequire "Implemented::data::function"
  assert_failure 2
  assert_lines_count 1
  assert_output --partial "ERROR   - Requirement 'Implemented::data::function' is not a valid require function name"
}

function Compiler::Require::assertRequire::BashFrameworkFunctionNotFound { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}"
  )
  local status=0
  Compiler::Require::assertRequire "Compiler::Require::requireNotFound" "${BATS_TEST_DIRNAME}" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "3" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Require function 'Compiler::Require::requireNotFound' cannot be found in any src dirs: ${BATS_TEST_DIRNAME}"
}

function Compiler::Require::assertRequire::validRequire { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  local status=0
  Compiler::Require::assertRequire "Namespace::requireSomething" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}
