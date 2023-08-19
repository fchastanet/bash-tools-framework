#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Require/parse.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/Compiler/Require/parse.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/Filters/removeExternalQuotes.sh"

assertRequireStatus=0

setup() {
  function Compiler::Require::assertRequire() {
    echo "Compiler::Require::assertRequire called"
    return ${assertRequireReturnStatus}
  }
  export -f Compiler::Require::assertRequire
}

teardown() {
  unset -f Compiler::Require::assertRequire
}

function Compiler::Require::parse::invalidRequire { #@test
  local file=""
  local functionName=""
  assertRequireReturnStatus=0
  local status=0
  Compiler::Require::parse '# ' functionName >${BATS_TEST_TMPDIR}/result 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${functionName}" = '' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 0
}

function Compiler::Require::parse::requireEmpty { #@test
  local file=""
  local functionName=""
  assertRequireReturnStatus=0
  local status=0
  Compiler::Require::parse '# @require ' functionName >${BATS_TEST_TMPDIR}/result 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${functionName}" = '' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 0
}

function Compiler::Require::parse::requireSimple { #@test
  local file=""
  local functionName=""
  assertRequireReturnStatus=0
  local status=0

  Compiler::Require::parse '# @require "interfaceFunction"' functionName >${BATS_TEST_TMPDIR}/result 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${functionName}" = 'interfaceFunction' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 "Compiler::Require::assertRequire called"
}

function Compiler::Require::parse::targetFile::withoutQuotes { #@test
  local file=""
  local functionName=""
  assertRequireReturnStatus=0
  local status=0

  Compiler::Require::parse '# @require Namespace::function' functionName >${BATS_TEST_TMPDIR}/result 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${functionName}" = 'Namespace::function' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 "Compiler::Require::assertRequire called"
}

function Compiler::Require::parse::invalidFunctionName { #@test
  assertRequireReturnStatus=1
  local file=""
  local functionName=""
  local status=0
  export BATS_TEST_DIRNAME
  Compiler::Require::parse $'# @require "interfaceFrançoisFunction"' \
    functionName >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "${functionName}" = 'interfaceFrançoisFunction' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output "Compiler::Require::assertRequire called"
}
