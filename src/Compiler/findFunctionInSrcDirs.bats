#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/findFunctionInSrcDirs.sh
source "${BATS_TEST_DIRNAME}/findFunctionInSrcDirs.sh"

function Compiler::findFunctionInSrcDirs::find1srcDir { #@test
  run Compiler::findFunctionInSrcDirs "Compiler::findFunctionInSrcDirs" "${srcDir}"
  assert_success
  assert_output "${srcDir}/Compiler/findFunctionInSrcDirs.sh"
}

function Compiler::findFunctionInSrcDirs::find2srcDirs { #@test
  run Compiler::findFunctionInSrcDirs "Functions::myFunction" \
    "${srcDir}" "${BATS_TEST_DIRNAME}/testsData"
  assert_success
  assert_output "${BATS_TEST_DIRNAME}/testsData/Functions/myFunction.sh"
}

function Compiler::findFunctionInSrcDirs::notFound { #@test
  run Compiler::findFunctionInSrcDirs "Functions::myFunctionNotFound" \
    "${srcDir}" "${BATS_TEST_DIRNAME}/testsData"
  assert_failure 1
  assert_output ""
}

function Compiler::findFunctionInSrcDirs::testExitCode1 { #@test
  local fileToImport=""
  local fails=0
  fileToImport="$(
    Compiler::findFunctionInSrcDirs \
      "Functions::myFunctionNotFound" "${BATS_TEST_DIRNAME}/testsData"
  )" || {
    fails=1
  }
  [[ "${fails}" = "1" ]]
  [[ "${fileToImport}" = "" ]]
}

function Compiler::findFunctionInSrcDirs::testExitCode0 { #@test
  local fileToImport=""
  local fails=0
  fileToImport="$(
    Compiler::findFunctionInSrcDirs \
      "Functions::myFunction" "${BATS_TEST_DIRNAME}/testsData"
  )" || {
    fails=1
  }
  [[ "${fails}" = "0" ]]
  [[ "${fileToImport}" = "${BATS_TEST_DIRNAME}/testsData/Functions/myFunction.sh" ]]

}
