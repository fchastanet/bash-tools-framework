#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/Facade/generateFacadeScript.sh
source "${srcDir}/Compiler/Facade/generateFacadeScript.sh"
# shellcheck source=/src/Compiler/Facade/generateMainFunctionName.sh
source "${srcDir}/Compiler/Facade/generateMainFunctionName.sh"
# shellcheck source=/src/Compiler/Facade/generateFacadeHeaders.sh
source "${srcDir}/Compiler/Facade/generateFacadeHeaders.sh"
# shellcheck source=/src/Compiler/Facade/generateFacadeContent.sh
source "${srcDir}/Compiler/Facade/generateFacadeContent.sh"
# shellcheck source=/src/Compiler/Facade/generateFacadeChoiceScript.sh
source "${srcDir}/Compiler/Facade/generateFacadeChoiceScript.sh"
# shellcheck source=/src/Compiler/Implement/interfaces.sh
source "${srcDir}/Compiler/Implement/interfaces.sh"
# shellcheck source=/src/Compiler/Implement/filter.sh
source "${srcDir}/Compiler/Implement/filter.sh"
# shellcheck source=/src/Compiler/Implement/parse.sh
source "${srcDir}/Compiler/Implement/parse.sh"
# shellcheck source=/src/Compiler/Implement/mergeInterfacesFunctions.sh
source "${srcDir}/Compiler/Implement/mergeInterfacesFunctions.sh"
# shellcheck source=/src/Framework/createTempFile.sh
source "${srcDir}/Framework/createTempFile.sh"
# shellcheck source=/src/Filters/directive.sh
source "${srcDir}/Filters/directive.sh"
# shellcheck source=/src/Filters/trimEmptyLines.sh
source "${srcDir}/Filters/trimEmptyLines.sh"
# shellcheck source=/src/Filters/removeExternalQuotes.sh
source "${srcDir}/Filters/removeExternalQuotes.sh"
# shellcheck source=/src/Compiler/Implement/assertInterface.sh
source "${srcDir}/Compiler/Implement/assertInterface.sh"
# shellcheck source=/src/Compiler/Implement/interfaceFunctions.sh
source "${srcDir}/Compiler/Implement/interfaceFunctions.sh"
# shellcheck source=/src/Assert/bashFrameworkFunction.sh
source "${srcDir}/Assert/bashFrameworkFunction.sh"
# shellcheck source=/src/Assert/posixFunctionName.sh
source "${srcDir}/Assert/posixFunctionName.sh"
# shellcheck source=/src/Compiler/Embed/getSrcDirsFromOptions.sh
source "${srcDir}/Compiler/Embed/getSrcDirsFromOptions.sh"
# shellcheck source=/src/Compiler/findFunctionInSrcDirs.sh
source "${srcDir}/Compiler/findFunctionInSrcDirs.sh"
# shellcheck source=/src/Crypto/uuidV4.sh
source "${srcDir}/Crypto/uuidV4.sh"

function Compiler::Facade::generateFacadeScript::EmptyFile { #@test
  run Compiler::Facade::generateFacadeScript "${BATS_TEST_DIRNAME}/testsData/script0Facade.sh" "template"
  assert_success
  assert_lines_count 6
  assert_line --index 0 --partial "WARN    - in ${BATS_TEST_DIRNAME}/testsData/script0Facade.sh - FACADE doesn't implement any interface"
  assert_line --index 1 --regexp "^export FACADE_HEADERS_FILE='/.*'$"
  assert_line --index 2 --regexp "^export FACADE_CONTENT_FILE='/.*'$"
  assert_line --index 3 --regexp "^export FACADE_CHOICE_SCRIPT_FILE='/.*'$"
  assert_line --index 4 --regexp "^export MAIN_FUNCTION_NAME='facade_main_[0-9a-f]{8}[0-9a-f]{4}4[0-9a-f]{3}[89ab][0-9a-f]{3}[0-9a-f]{12}'$"
  assert_line --index 5 "export file='template'"

  local script="$(tail +2 <<<"${output}")"
  eval "${script}"
  [[ -z "$(cat "${FACADE_HEADERS_FILE}")" ]]
  diff "${FACADE_CONTENT_FILE}" "${BATS_TEST_DIRNAME}/testsData/generateFacadeScript.emptyFile.content.expected.txt" >&3
  [[ -z "$(cat "${FACADE_CHOICE_SCRIPT_FILE}")" ]]
}

function Compiler::Facade::generateFacadeScript::FacadeWithoutImplement { #@test
  run Compiler::Facade::generateFacadeScript "${BATS_TEST_DIRNAME}/testsData/script1Facade.sh" "template"
  assert_success
  assert_lines_count 6
  assert_line --index 0 --partial "WARN    - in ${BATS_TEST_DIRNAME}/testsData/script1Facade.sh - FACADE doesn't implement any interface"
  assert_line --index 1 --regexp "^export FACADE_HEADERS_FILE='/.*'$"
  assert_line --index 2 --regexp "^export FACADE_CONTENT_FILE='/.*'$"
  assert_line --index 3 --regexp "^export FACADE_CHOICE_SCRIPT_FILE='/.*'$"
  assert_line --index 4 --regexp "^export MAIN_FUNCTION_NAME='facade_main_[0-9a-f]{8}[0-9a-f]{4}4[0-9a-f]{3}[89ab][0-9a-f]{3}[0-9a-f]{12}'$"
  assert_line --index 5 "export file='template'"

  local script="$(tail +2 <<<"${output}")"
  eval "${script}"
  [[ "$(cat "${FACADE_HEADERS_FILE}")" = '# FACADE "_includes/facadeDefault/facadeDefault.tpl"' ]]
  diff "${FACADE_CONTENT_FILE}" "${BATS_TEST_DIRNAME}/testsData/generateFacadeScript.emptyFile.content.expected.txt" >&3
  [[ -z "$(cat "${FACADE_CHOICE_SCRIPT_FILE}")" ]]
}

function Compiler::Facade::generateFacadeScript::FacadeWithImplementButImplementFunctionNotFound { #@test
  run Compiler::Facade::generateFacadeScript "${BATS_TEST_DIRNAME}/testsData/longerScript.sh" "template"
  assert_failure 3
  assert_lines_count 1
  assert_output --partial "ERROR   - Interface 'Install::InstallInterface' cannot be found in any src dirs:"
}

function Compiler::Facade::generateFacadeScript::facadeWithImplementImplementFunctionFound { #@test
  export _COMPILE_FILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  run Compiler::Facade::generateFacadeScript "${BATS_TEST_DIRNAME}/testsData/longerScript.sh" "template"
  assert_success

  assert_lines_count 5
  assert_line --index 0 --regexp "^export FACADE_HEADERS_FILE='/.*'$"
  assert_line --index 1 --regexp "^export FACADE_CONTENT_FILE='/.*'$"
  assert_line --index 2 --regexp "^export FACADE_CHOICE_SCRIPT_FILE='/.*'$"
  assert_line --index 3 --regexp "^export MAIN_FUNCTION_NAME='facade_main_[0-9a-f]{8}[0-9a-f]{4}4[0-9a-f]{3}[89ab][0-9a-f]{3}[0-9a-f]{12}'$"
  assert_line --index 4 "export file='template'"

  eval "${output}"
  [[ "$(cat "${FACADE_HEADERS_FILE}")" = "$(cat "${BATS_TEST_DIRNAME}/testsData/facadeWithImplementImplementFunctionFound.headers.expected.txt")" ]]
  diff "${FACADE_CONTENT_FILE}" "${BATS_TEST_DIRNAME}/testsData/facadeWithImplementImplementFunctionFound.content.expected.txt" >&3
  diff "${FACADE_CHOICE_SCRIPT_FILE}" "${BATS_TEST_DIRNAME}/testsData/facadeWithImplementImplementFunctionFound.choiceScript.expected.txt" >&3
}
