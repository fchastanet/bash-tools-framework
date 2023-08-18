#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/Facade/generateFacadeContent.sh
source "${srcDir}/Compiler/Facade/generateFacadeContent.sh"
# shellcheck source=/src/Filters/directive.sh
source "${srcDir}/Filters/directive.sh"

function Compiler::Facade::generateFacadeContent::script2Facades { #@test
  run Compiler::Facade::generateFacadeContent "${BATS_TEST_DIRNAME}/testsData/script2Facades.sh"
  assert_success
  assert_output ""
}

function Compiler::Facade::generateFacadeContent::longerScript { #@test
  run Compiler::Facade::generateFacadeContent "${BATS_TEST_DIRNAME}/testsData/longerScript.sh"
  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/generateFacadeContent.longerScript.expected.txt")"
}
