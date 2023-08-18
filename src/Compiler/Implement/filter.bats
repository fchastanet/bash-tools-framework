#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Implement/filter.sh
source "${srcDir}/Compiler/Implement/filter.sh"

function Compiler::Implement::filter::noMatch { #@test
  run Compiler::Implement::filter "${BATS_TEST_DIRNAME}/testsData/binaryFile"
  assert_success
  assert_output ""
}

function Compiler::Implement::filter::stdin { #@test

  echo "# IMPLEMENT file" | {
    run Compiler::Implement::filter
    assert_success
    assert_output "# IMPLEMENT file"
  }
}

function Compiler::Implement::filter::fileArg { #@test
  run Compiler::Implement::filter "${BATS_TEST_DIRNAME}/testsData/filter.sh"
  assert_success
  assert_lines_count 4
  assert_line --index 0 '# IMPLEMENT "Namespace::interfaceValidList"'
  assert_line --index 1 '# IMPLEMENT Namespace::interfaceValidList'
  assert_line --index 2 '# IMPLEMENT "${BATS_TEST_DIRNAME}/test'
  assert_line --index 3 '# IMPLEMENT EST_DIRNAME}/test"'
}
