#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Embed/parseInclude.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/Embed/parseInclude.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/Filters/removeExternalQuotes.sh"

# INCLUDE "srcDir" AS "targetDir"
# INCLUDE namespace::functions AS "myFunction"

assertAsNameReturnStatus=0
assertResourceReturnStatus=0

setup() {
  function Embed::assertAsName() {
    echo "Embed::assertAsName called"
    return ${assertAsNameReturnStatus}
  }
  function Embed::assertResource() {
    echo "Embed::assertResource called"
    return ${assertResourceReturnStatus}
  }
  export -f Embed::assertAsName
  export -f Embed::assertResource
}

teardown() {
  unset -f Embed::assertAsName
  unset -f Embed::assertResource
}

function Embed::parseInclude::targetFile::simple { #@test
  local file=""
  local asName=""
  Embed::parseInclude '# INCLUDE "srcFile" AS "targetFile"' file asName >${BATS_TEST_TMPDIR}/result 2>&1
  [[ "${file}" = 'srcFile' ]]
  [[ "${asName}" = 'targetFile' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "Embed::assertAsName called"
  assert_line --index 1 "Embed::assertResource called"
}

function Embed::parseInclude::targetFile::withVars { #@test
  local file=""
  local asName=""
  Embed::parseInclude $'# INCLUDE "${BATS_TEST_DIRNAME}/test" AS targetFile' file asName >${BATS_TEST_TMPDIR}/result 2>&1
  [[ "${file}" = $'${BATS_TEST_DIRNAME}/test' ]]
  [[ "${asName}" = 'targetFile' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "Embed::assertAsName called"
  assert_line --index 1 "Embed::assertResource called"
}

function Embed::parseInclude::invalidAsName { #@test
  assertAsNameReturnStatus=1
  local file=""
  local asName=""
  Embed::parseInclude $'# INCLUDE "${BATS_TEST_DIRNAME}/test" AS targetFile0-7ù' \
    file asName >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "${file}" = $'${BATS_TEST_DIRNAME}/test' ]]
  [[ "${asName}" = 'targetFile0-7ù' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output "Embed::assertAsName called"
}

function Embed::parseInclude::invalidResource { #@test
  assertResourceReturnStatus=1
  local file=""
  local asName=""
  Embed::parseInclude $'# INCLUDE "invalid" AS targetFile' \
    file asName >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "2" ]]
  [[ "${file}" = 'invalid' ]]
  [[ "${asName}" = 'targetFile' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "Embed::assertAsName called"
  assert_line --index 1 "Embed::assertResource called"
}
