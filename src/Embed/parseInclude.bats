#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/Embed/parseInclude.sh"
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/Filters/removeExternalQuotes.sh"

# INCLUDE "srcDir" AS "targetDir"
# INCLUDE namespace::functions AS "myFunction"

# INCLUDE "srcFile" AS "targetFile"
function Embed::parseInclude::targetFile { #@test
  local file=""
  local asName=""
  Embed::parseInclude '# INCLUDE "srcFile" AS "targetFile"' file asName
  [[ "${file}" = 'srcFile' ]]
  [[ "${asName}" = 'targetFile' ]]
}

# INCLUDE "${BATS_TEST_DIRNAME}/test" AS targetFile
function Embed::parseInclude::targetFile::withVars { #@test
  local file=""
  local asName=""
  Embed::parseInclude $'# INCLUDE "${BATS_TEST_DIRNAME}/test" AS targetFile' file asName
  [[ "${file}" = $'${BATS_TEST_DIRNAME}/test' ]]
  [[ "${asName}" = 'targetFile' ]]
}
