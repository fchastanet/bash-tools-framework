#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Facade/filter.sh
source "${srcDir}/Compiler/Facade/filter.sh"

function Compiler::Facade::filter::noMatch { #@test
  run Compiler::Facade::filter "${BATS_TEST_DIRNAME}/testsData/script0Facade.sh"
  assert_success
  assert_output ""
}

function Compiler::Facade::filter::stdin { #@test

  echo "# FACADE facade" | {
    run Compiler::Facade::filter
    assert_success
    assert_output "# FACADE facade"
  }
}

function Compiler::Facade::filter::1Facade { #@test
  run Compiler::Facade::filter "${BATS_TEST_DIRNAME}/testsData/script1Facade.sh"
  assert_success
  assert_lines_count 1
  assert_line --index 0 '# FACADE "_includes/facadeDefault/facadeDefault.tpl"'
}

# this is not possible but the check is not done in this function
function Compiler::Facade::filter::2Facades { #@test
  run Compiler::Facade::filter "${BATS_TEST_DIRNAME}/testsData/script2Facades.sh"
  assert_success
  assert_lines_count 2
  assert_line --index 0 '# FACADE'
  assert_line --index 1 '# FACADE "_includes/facade2.tpl"'
}
