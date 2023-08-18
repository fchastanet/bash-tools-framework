#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Embed/parse.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/Compiler/Embed/parse.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/Filters/removeExternalQuotes.sh"

# EMBED "srcDir" AS "targetDir"
# EMBED Namespace::functions AS "myFunction"

assertAsNameReturnStatus=0
assertResourceReturnStatus=0

setup() {
  function Compiler::Embed::assertAsName() {
    echo "Compiler::Embed::assertAsName called"
    return ${assertAsNameReturnStatus}
  }
  function Compiler::Embed::assertResource() {
    echo "Compiler::Embed::assertResource called"
    return ${assertResourceReturnStatus}
  }
  export -f Compiler::Embed::assertAsName
  export -f Compiler::Embed::assertResource
}

teardown() {
  unset -f Compiler::Embed::assertAsName
  unset -f Compiler::Embed::assertResource
}

function Compiler::Embed::parse::targetFile::simple { #@test
  local file=""
  local asName=""
  assertAsNameReturnStatus=0
  assertResourceReturnStatus=0

  Compiler::Embed::parse '# EMBED "srcFile" AS "targetFile"' file asName >${BATS_TEST_TMPDIR}/result 2>&1
  [[ "${file}" = 'srcFile' ]]
  [[ "${asName}" = 'targetFile' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "Compiler::Embed::assertAsName called"
  assert_line --index 1 "Compiler::Embed::assertResource called"
}

function Compiler::Embed::parse::targetFile::withVars { #@test
  local file=""
  local asName=""
  assertAsNameReturnStatus=0
  assertResourceReturnStatus=0

  export BATS_TEST_DIRNAME
  Compiler::Embed::parse $'# EMBED "${BATS_TEST_DIRNAME}/test" AS targetFile' file asName >${BATS_TEST_TMPDIR}/result 2>&1

  [[ "${file}" = "${BATS_TEST_DIRNAME}/test" ]]
  [[ "${asName}" = 'targetFile' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "Compiler::Embed::assertAsName called"
  assert_line --index 1 "Compiler::Embed::assertResource called"
}

function Compiler::Embed::parse::invalidAsName { #@test
  assertAsNameReturnStatus=1
  local file=""
  local asName=""
  export BATS_TEST_DIRNAME
  Compiler::Embed::parse $'# EMBED "${BATS_TEST_DIRNAME}/test" AS targetFile0-7ù' \
    file asName >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "${file}" = "${BATS_TEST_DIRNAME}/test" ]]
  [[ "${asName}" = 'targetFile0-7ù' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output "Compiler::Embed::assertAsName called"
}

function Compiler::Embed::parse::invalidResource { #@test
  assertResourceReturnStatus=1
  local file=""
  local asName=""
  Compiler::Embed::parse $'# EMBED "invalid" AS targetFile' \
    file asName >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "2" ]]
  [[ "${file}" = 'invalid' ]]
  [[ "${asName}" = 'targetFile' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "Compiler::Embed::assertAsName called"
  assert_line --index 1 "Compiler::Embed::assertResource called"
}
