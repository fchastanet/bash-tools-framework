#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Facade/restoreOldMainFunctionName.sh
source "${srcDir}/Compiler/Facade/restoreOldMainFunctionName.sh"

function Compiler::Facade::restoreOldMainFunctionName::noMatch { #@test
  cat "${BATS_TEST_DIRNAME}/testsData/restoreOldMainFunctionName.noMain" | {
    run Compiler::Facade::restoreOldMainFunctionName "${BATS_TEST_DIRNAME}/testsData/restoreOldMainFunctionName.noMain"
    assert_success
    assert_output "$(cat ${BATS_TEST_DIRNAME}/testsData/restoreOldMainFunctionName.noMain)"
  }
}

function Compiler::Facade::restoreOldMainFunctionName::fileNotFound { #@test
  cat "${BATS_TEST_DIRNAME}/testsData/restoreOldMainFunctionName.installFacadeExample" | {
    run Compiler::Facade::restoreOldMainFunctionName "${BATS_TEST_DIRNAME}/testsData/binFileNotGeneratedYet"
    assert_success
    assert_output "$(cat ${BATS_TEST_DIRNAME}/testsData/restoreOldMainFunctionName.installFacadeExample)"
  }
}

function Compiler::Facade::restoreOldMainFunctionName::facade { #@test
  cat "${BATS_TEST_DIRNAME}/testsData/restoreOldMainFunctionName.installFacadeExample.newGeneration" | {
    run Compiler::Facade::restoreOldMainFunctionName "${BATS_TEST_DIRNAME}/testsData/restoreOldMainFunctionName.installFacadeExample"
    assert_success
    diff <(echo "${output}") "${BATS_TEST_DIRNAME}/testsData/restoreOldMainFunctionName.installFacadeExample" >&3
  }
}
