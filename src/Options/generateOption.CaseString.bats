#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Options/generateOption.sh
source "${srcDir}/Options/generateOption.sh"
# shellcheck source=src/Options/generateFunctionName.sh
source "${srcDir}/Options/generateFunctionName.sh"
# shellcheck source=src/Options/generateOptionString.sh
source "${srcDir}/Options/generateOptionString.sh"
# shellcheck source=src/Options/assertAlt.sh
source "${srcDir}/Options/assertAlt.sh"
# shellcheck source=src/Options/bashTpl.sh
source "${srcDir}/Options/bashTpl.sh"
# shellcheck source=/src/Assert/validVariableName.sh
source "${srcDir}/Assert/validVariableName.sh"
# shellcheck source=/src/Array/contains.sh
source "${srcDir}/Array/contains.sh"
# shellcheck source=/src/Array/join.sh
source "${srcDir}/Array/join.sh"
# shellcheck source=/src/Framework/createTempFile.sh
source "${srcDir}/Framework/createTempFile.sh"
# shellcheck source=/src/Crypto/uuidV4.sh
source "${srcDir}/Crypto/uuidV4.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
}

# Options::generateOption::caseString1::Success ensures
# that testsData/generateOption.caseString1.sh is up to date
# Case 1: 1 --alt
function Options::generateOption::caseString1::success { #@test
  run Options::generateOption --type String --variable-name "varName" --alt "--var"
  assert_success
  assert_lines_count 1
  # output is the function name generated
  assert_output --regexp $'^Options::optionVarName[A-F0-9][a-f0-9]{31}$'
  local functionName="${output}"

  # check function content
  local tmpFile
  tmpFile="${TMPDIR}/src/$(sed -E -e 's#::#/#' <<<"${functionName}")"
  [[ -f "${tmpFile}" ]]
  sed -i -E "s#^Options::optionVarName[A-F0-9][a-f0-9]{31}#Options::optionVarName#" "${tmpFile}"
  diff "${tmpFile}" "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString1.sh" >&3 || {
    cat "${tmpFile}" >&3
    return 1
  }
}

function Options::generateOption::caseString1::OptionTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString1.sh"
  run Options::optionVarName
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Option command invalid: ''"
}

function Options::generateOption::caseString1::OptionTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString1.sh"
  local status=0
  local varName="somethingElse"
  Options::optionVarName parse --var >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Option --var - a value needs to be specified"
  [[ "${varName}" = "somethingElse" ]]
}

function Options::generateOption::caseString1::OptionTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString1.sh"
  local status=0
  local varName="somethingElse"
  Options::optionVarName parse --var newValue >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "newValue" ]]
}

function Options::generateOption::caseString1::OptionTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString1.sh"
  run Options::optionVarName help
  assert_lines_count 2
  assert_line --index 0 --partial "  --var (optional)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseString2Success ensures
# that testsData/generateOption.caseString2.sh is up to date
# Case 2: 2 --alt
function Options::generateOption::caseString2::success { #@test
  run Options::generateOption --type String --variable-name "varName" --alt "--var" --alt "-v"
  assert_success
  assert_lines_count 1
  # output is the function name generated
  assert_output --regexp $'^Options::optionVarName[A-F0-9][a-f0-9]{31}$'
  local functionName="${output}"

  # check function content
  local tmpFile
  tmpFile="${TMPDIR}/src/$(sed -E -e 's#::#/#' <<<"${functionName}")"
  [[ -f "${tmpFile}" ]]
  sed -i -E "s#^Options::optionVarName[A-F0-9][a-f0-9]{31}#Options::optionVarName#" "${tmpFile}"
  diff "${tmpFile}" "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString2.sh" >&3 || {
    cat "${tmpFile}" >&3
    return 1
  }
}

function Options::generateOption::caseString2::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString2.sh"
  run Options::optionVarName
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Option command invalid: ''"
}

function Options::generateOption::caseString2::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString2.sh"
  local status=0
  local varName="somethingElse"
  Options::optionVarName parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "somethingElse" ]]
}

function Options::generateOption::caseString2::OptionsTest::parseWithArgAlt1 { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString2.sh"
  local status=0
  local varName="somethingElse"
  Options::optionVarName parse --var "newValue" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "newValue" ]]
}

function Options::generateOption::caseString2::OptionsTest::parseWithArgAlt2 { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString2.sh"
  local status=0
  local varName="somethingElse"
  Options::optionVarName parse -v "newValue" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "newValue" ]]
}

function Options::generateOption::caseString2::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString2.sh"
  run Options::optionVarName help
  assert_lines_count 2
  assert_line --index 0 --partial "  --var, -v (optional)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseString4 ensures
# that testsData/generateOption.caseString3.sh is up to date
# Case 3: 2 --alt + mandatory
function Options::generateOption::caseString3::success { #@test
  run Options::generateOption --type String --variable-name "varName" \
    --alt "--var" --alt "-v" --mandatory
  assert_success
  assert_lines_count 1
  # output is the function name generated
  assert_output --regexp $'^Options::optionVarName[A-F0-9][a-f0-9]{31}$'
  local functionName="${output}"

  # check function content
  local tmpFile
  tmpFile="${TMPDIR}/src/$(sed -E -e 's#::#/#' <<<"${functionName}")"
  [[ -f "${tmpFile}" ]]
  sed -i -E "s#^Options::optionVarName[A-F0-9][a-f0-9]{31}#Options::optionVarName#" "${tmpFile}"
  diff "${tmpFile}" "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString3.sh" >&3 || {
    cat "${tmpFile}" >&3
    return 1
  }
}

function Options::generateOption::caseString3::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString3.sh"
  run Options::optionVarName
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Option command invalid: ''"
}

function Options::generateOption::caseString3::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString3.sh"
  local status=0
  local varName="somethingElse"
  Options::optionVarName parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Option '--var' should be provided"
  [[ "${varName}" = "somethingElse" ]]
}

function Options::generateOption::caseString3::OptionsTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString3.sh"
  local status=0
  local varName="somethingElse"
  Options::optionVarName parse --var NewValue >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "NewValue" ]]
}

function Options::generateOption::caseString3::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString3.sh"
  run Options::optionVarName help
  assert_lines_count 2
  assert_line --index 0 --partial "  --var, -v (mandatory)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseString4 ensures
# that testsData/generateOption.caseString4.sh is up to date
# Case 3: 2 --alt + mandatory + custom help
function Options::generateOption::caseString4::success { #@test
  run Options::generateOption --type String --variable-name "varName" \
    --alt "--var" --alt "-v" --mandatory --help "super help"
  assert_success
  assert_lines_count 1
  # output is the function name generated
  assert_output --regexp $'^Options::optionVarName[A-F0-9][a-f0-9]{31}$'
  local functionName="${output}"

  # check function content
  local tmpFile
  tmpFile="${TMPDIR}/src/$(sed -E -e 's#::#/#' <<<"${functionName}")"
  [[ -f "${tmpFile}" ]]
  sed -i -E "s#^Options::optionVarName[A-F0-9][a-f0-9]{31}#Options::optionVarName#" "${tmpFile}"
  diff "${tmpFile}" "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString4.sh" >&3 || {
    cat "${tmpFile}" >&3
    return 1
  }
}

function Options::generateOption::caseString4::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString4.sh"
  run Options::optionVarName
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Option command invalid: ''"
}

function Options::generateOption::caseString4::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString4.sh"
  local status=0
  local varName="somethingElse"
  Options::optionVarName parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Option '--var' should be provided"
  [[ "${varName}" = "somethingElse" ]]
}

function Options::generateOption::caseString4::OptionsTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString4.sh"
  local status=0
  local varName="somethingElse"
  Options::optionVarName parse --var "NewValue" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "NewValue" ]]
}

function Options::generateOption::caseString4::OptionsTest::parseMultipleArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString4.sh"
  local status=0
  local varName="somethingElse"
  Options::optionVarName parse --var "NewValue" -v "NewValue2" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output --partial "ERROR   - Option -v - Maximum number of option occurrences reached(1)"
  [[ "${varName}" = "NewValue" ]]
}

function Options::generateOption::caseString4::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseString4.sh"
  run Options::optionVarName help
  assert_lines_count 2
  assert_line --index 0 --partial "  --var, -v (mandatory)"
  assert_line --index 1 "    super help"
}
