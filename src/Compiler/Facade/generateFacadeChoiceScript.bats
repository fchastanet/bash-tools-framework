#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/Facade/generateFacadeChoiceScript.sh
source "${srcDir}/Compiler/Facade/generateFacadeChoiceScript.sh"
# shellcheck source=/src/Compiler/Implement/mergeInterfacesFunctions.sh
source "${srcDir}/Compiler/Implement/mergeInterfacesFunctions.sh"
# shellcheck source=/src/Compiler/Implement/interfaceFunctions.sh
source "${srcDir}/Compiler/Implement/interfaceFunctions.sh"
# shellcheck source=/src/Compiler/Implement/assertInterface.sh
source "${srcDir}/Compiler/Implement/assertInterface.sh"
# shellcheck source=/src/Compiler/Implement/filter.sh
source "${srcDir}/Compiler/Implement/filter.sh"
# shellcheck source=/src/Compiler/Implement/parse.sh
source "${srcDir}/Compiler/Implement/parse.sh"
# shellcheck source=/src/Compiler/Implement/interfaces.sh
source "${srcDir}/Compiler/Implement/interfaces.sh"
# shellcheck source=/src/Compiler/Embed/getSrcDirsFromOptions.sh
source "${srcDir}/Compiler/Embed/getSrcDirsFromOptions.sh"
# shellcheck source=/src/Compiler/findFunctionInSrcDirs.sh
source "${srcDir}/Compiler/findFunctionInSrcDirs.sh"
# shellcheck source=/src/Filters/trimEmptyLines.sh
source "${srcDir}/Filters/trimEmptyLines.sh"
# shellcheck source=/src/Filters/removeExternalQuotes.sh
source "${srcDir}/Filters/removeExternalQuotes.sh"
# shellcheck source=/src/Assert/bashFrameworkFunction.sh
source "${srcDir}/Assert/bashFrameworkFunction.sh"
# shellcheck source=/src/Assert/posixFunctionName.sh
source "${srcDir}/Assert/posixFunctionName.sh"

function Compiler::Facade::generateFacadeChoiceScript::NoImplementDirective { #@test
  local scriptFile="${BATS_TEST_DIRNAME}/testsData/generateFacadeChoiceScript.noImplementDirective.sh"
  run Compiler::Facade::generateFacadeChoiceScript "${scriptFile}"
  assert_failure 2
  assert_lines_count 1
  assert_output --partial "WARN    - in ${scriptFile} - FACADE doesn't implement any interface"
}

function Compiler::Facade::generateFacadeChoiceScript::OneImplementDirective { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  local scriptFile="${BATS_TEST_DIRNAME}/testsData/generateFacadeChoiceScript.oneImplementDirective.sh"
  local status=0
  export _COMPILE_FILE_ARGUMENTS
  Compiler::Facade::generateFacadeChoiceScript "${scriptFile}" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  diff "${BATS_TEST_TMPDIR}/result" "${BATS_TEST_DIRNAME}/testsData/generateFacadeChoiceScript.oneImplementDirective.expected.txt" >&3 || return 1
}

function Compiler::Facade::generateFacadeChoiceScript::TwoImplementDirective { #@test
  local -a _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  local scriptFile="${BATS_TEST_DIRNAME}/testsData/generateFacadeChoiceScript.twoImplementDirective.sh"
  local status=0
  export _COMPILE_FILE_ARGUMENTS
  Compiler::Facade::generateFacadeChoiceScript "${scriptFile}" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  diff "${BATS_TEST_TMPDIR}/result" "${BATS_TEST_DIRNAME}/testsData/generateFacadeChoiceScript.twoImplementDirective.expected.txt" >&3 || return 1
}
