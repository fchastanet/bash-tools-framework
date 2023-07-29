#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Embed/filterIncludes.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/Embed/filterIncludes.sh"

function Embed::filterIncludes::noMatch { #@test
  run Embed::filterIncludes "${BATS_TEST_DIRNAME}/testsData/binaryFile"
  assert_success
  assert_output ""
}

function Embed::filterIncludes::stdin { #@test

  echo "# INCLUDE "srcDir" AS "targetDir"" | {
    run Embed::filterIncludes
    assert_success
    assert_output "# INCLUDE "srcDir" AS "targetDir""
  }
}

function Embed::filterIncludes::fileArg { #@test
  run Embed::filterIncludes "${BATS_TEST_DIRNAME}/testsData/filterIncludes.sh"
  assert_success
  assert_lines_count 4
  assert_line --index 0 '# INCLUDE "srcDir" As "targetDir"'
  assert_line --index 1 '# INCLUDE namespace::functions AS "myFunction"'
  assert_line --index 2 '# INCLUDE "Backup::file" as backupFile'
  assert_line --index 3 '# INCLUDE "${BATS_TEST_DIRNAME}/test" AS targetFile0-7ù'
}
