#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Require/filter.sh
source "${srcDir}/Compiler/Require/filter.sh"

function Compiler::Require::filter::noMatch { #@test
  run Compiler::Require::filter "${BATS_TEST_DIRNAME}/testsData/binaryFile"
  assert_success
  assert_output ""
}

function Compiler::Require::filter::stdin { #@test

  echo "# @require function" | {
    run Compiler::Require::filter
    assert_success
    assert_output "# @require function"
  }
}

function Compiler::Require::filter::stdinWithSpaces { #@test

  echo -e " \t # @require function" | {
    run Compiler::Require::filter
    assert_success
    assert_output ""
  }
}

function Compiler::Require::filter::function { #@test
  run Compiler::Require::filter "${BATS_TEST_DIRNAME}/testsData/filter.sh"
  assert_success
  assert_lines_count 4
  assert_line --index 0 '# @require "Namespace::requireSomething"'
  assert_line --index 1 '# @require Namespace::requireSomething'
  # assert will help then to eliminate that cases
  assert_line --index 2 '# @require "${BATS_TEST_DIRNAME}/test'
  assert_line --index 3 '# @require EST_DIRNAME}/test"'
}
