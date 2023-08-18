#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/Facade/generateFacadeHeaders.sh
source "${srcDir}/Compiler/Facade/generateFacadeHeaders.sh"
# shellcheck source=/src/Filters/directive.sh
source "${srcDir}/Filters/directive.sh"

function Compiler::Facade::generateFacadeHeaders::script2Facades { #@test
  run Compiler::Facade::generateFacadeHeaders "${BATS_TEST_DIRNAME}/testsData/script2Facades.sh"
  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/generateFacadeHeaders.script2Facades.expected.txt")"
}

function Compiler::Facade::generateFacadeHeaders::longerScript { #@test
  run Compiler::Facade::generateFacadeHeaders "${BATS_TEST_DIRNAME}/testsData/longerScript.sh"
  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/generateFacadeHeaders.longerScript.expected.txt")"
}
