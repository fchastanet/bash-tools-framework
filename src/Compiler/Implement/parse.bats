#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Implement/parse.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/Compiler/Implement/parse.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/Filters/removeExternalQuotes.sh"

assertInterfaceStatus=0

setup() {
  function Compiler::Implement::assertInterface() {
    echo "Compiler::Implement::assertInterface called"
    return ${assertInterfaceReturnStatus}
  }
  export -f Compiler::Implement::assertInterface
}

teardown() {
  unset -f Compiler::Implement::assertInterface
}

function Compiler::Implement::parse::targetFile::empty { #@test
  local file=""
  local functionName=""
  assertInterfaceReturnStatus=0

  Compiler::Implement::parse '# IMPLEMENT ' functionName >${BATS_TEST_TMPDIR}/result 2>&1
  [[ "${functionName}" = '' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 0
}

function Compiler::Implement::parse::targetFile::simple { #@test
  local file=""
  local functionName=""
  assertInterfaceReturnStatus=0

  Compiler::Implement::parse '# IMPLEMENT "interfaceFunction"' functionName >${BATS_TEST_TMPDIR}/result 2>&1
  [[ "${functionName}" = 'interfaceFunction' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 "Compiler::Implement::assertInterface called"
}

function Compiler::Implement::parse::targetFile::withoutQuotes { #@test
  local file=""
  local functionName=""
  assertInterfaceReturnStatus=0

  Compiler::Implement::parse '# IMPLEMENT namespace::function' functionName >${BATS_TEST_TMPDIR}/result 2>&1
  [[ "${functionName}" = 'namespace::function' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 "Compiler::Implement::assertInterface called"
}

function Compiler::Implement::parse::invalidFunctionName { #@test
  assertInterfaceReturnStatus=1
  local file=""
  local functionName=""
  export BATS_TEST_DIRNAME
  Compiler::Implement::parse $'# IMPLEMENT "interfaceFrançoisFunction"' \
    functionName >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "${functionName}" = 'interfaceFrançoisFunction' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output "Compiler::Implement::assertInterface called"
}
