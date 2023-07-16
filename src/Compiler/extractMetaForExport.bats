#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/extractMetaForExport.sh
source "${BATS_TEST_DIRNAME}/extractMetaForExport.sh"

function Compiler::extractMetaForExport::OneMeta { #@test
  run Compiler::extractMetaForExport "${BATS_TEST_DIRNAME}/testsData/meta1.sh"
  assert_success
  assert_lines_count 2
  assert_line --index 0 'VAR="VALUE"'
  assert_line --index 1 'export VAR'
}

function Compiler::extractMetaForExport::TwoMeta { #@test
  run Compiler::extractMetaForExport "${BATS_TEST_DIRNAME}/testsData/meta2.sh"
  assert_success
  assert_lines_count 4
  assert_line --index 0 'VAR="VALUE"'
  assert_line --index 1 'export VAR'
  assert_line --index 2 'VAR2="VALUE2"'
  assert_line --index 3 'export VAR2'
}

function Compiler::extractMetaForExport::ThreeMetaButSpaces { #@test
  run Compiler::extractMetaForExport "${BATS_TEST_DIRNAME}/testsData/meta3.sh"
  # the third var is not read
  assert_success
  assert_lines_count 4
  assert_line --index 0 'VAR="VALUE"'
  assert_line --index 1 'export VAR'
  assert_line --index 2 'VAR2="VALUE2"'
  assert_line --index 3 'export VAR2'
}

function Compiler::extractMetaForExport::TwoMeta::eval { #@test
  run Compiler::extractMetaForExport "${BATS_TEST_DIRNAME}/testsData/meta2.sh"
  assert_success
  (
    # shellcheck disable=SC2154
    eval "${output}"
    [[ "${VAR}" = "VALUE" ]]
    [[ "${VAR2}" = "VALUE2" ]]
  )
}
