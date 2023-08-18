#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Embed/filter.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/Compiler/Embed/filter.sh"

function Compiler::Embed::filter::noMatch { #@test
  run Compiler::Embed::filter "${BATS_TEST_DIRNAME}/testsData/binaryFile"
  assert_success
  assert_output ""
}

function Compiler::Embed::filter::stdin { #@test

  echo "# EMBED "srcDir" AS "targetDir"" | {
    run Compiler::Embed::filter
    assert_success
    assert_output "# EMBED "srcDir" AS "targetDir""
  }
}

function Compiler::Embed::filter::fileArg { #@test
  run Compiler::Embed::filter "${BATS_TEST_DIRNAME}/testsData/filter.sh"
  assert_success
  assert_lines_count 4
  assert_line --index 0 '# EMBED "srcDir" As "targetDir"'
  assert_line --index 1 '# EMBED Namespace::functions AS "myFunction"'
  assert_line --index 2 '# EMBED "Backup::file" as backupFile'
  assert_line --index 3 '# EMBED "${BATS_TEST_DIRNAME}/test" AS targetFile0-7ù'
}
