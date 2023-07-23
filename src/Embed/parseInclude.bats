#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/Embed/parseInclude.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/Filters/removeExternalQuotes.sh"

# INCLUDE "srcDir" AS "targetDir"
# INCLUDE namespace::functions AS "myFunction"

function Embed::parseInclude::targetFile { #@test
  local file=""
  local asName=""
  Embed::parseInclude '# INCLUDE "srcFile" AS "targetFile"' file asName
  [[ "${file}" = 'srcFile' ]]
  [[ "${asName}" = 'targetFile' ]]
}

function Embed::parseInclude::targetFile::withVars { #@test
  local file=""
  local asName=""
  Embed::parseInclude $'# INCLUDE "${BATS_TEST_DIRNAME}/test" AS targetFile' file asName
  [[ "${file}" = $'${BATS_TEST_DIRNAME}/test' ]]
  [[ "${asName}" = 'targetFile' ]]
}

function Embed::parseInclude::invalidAsName { #@test
  local file=""
  local asName=""
  Embed::parseInclude $'# INCLUDE "${BATS_TEST_DIRNAME}/test" AS targetFile0-7ù' \
    file asName 2>"${BATS_RUN_TMPDIR}/result" || status=$?
  [[ "${status}" = "1" ]]
  [[ "${file}" = $'${BATS_TEST_DIRNAME}/test' ]]
  [[ "${asName}" = 'targetFile0-7ù' ]]
  [[ "$(cat "${BATS_RUN_TMPDIR}/result")" =~ (AS property name can only be composed by letters,) ]]
}
