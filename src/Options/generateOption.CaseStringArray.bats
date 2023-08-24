#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Options/generateOption.sh
source "${srcDir}/Options/generateOption.sh"
# shellcheck source=src/Options/generateFunctionName.sh
source "${srcDir}/Options/generateFunctionName.sh"
# shellcheck source=src/Options/generateOptionStringArray.sh
source "${srcDir}/Options/generateOptionStringArray.sh"
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

# Options::generateOption::caseStringArray1::Success ensures
# that testsData/generateOption.caseStringArray1.sh is up to date
# Case 1: 1 --alt
function Options::generateOption::caseStringArray1::success { #@test
  run Options::generateOption --type StringArray --variable-name "varName" --alt "--var"
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
  diff "${tmpFile}" "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray1.sh" >&3 || {
    cat "${tmpFile}" >&3
    return 1
  }
}

function Options::generateOption::caseStringArray1::OptionTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray1.sh"
  run Options::optionVarName
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Option command invalid: ''"
}

function Options::generateOption::caseStringArray1::OptionTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray1.sh"
  local status=0
  local -a varName=()
  Options::optionVarName parse --var >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Option --var - a value needs to be specified"
  [[ "${#varName[@]}" = "0" ]]
}

function Options::generateOption::caseStringArray1::OptionTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray1.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse --var newValue >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "2" ]]
  [[ "${varName[*]}" = "somethingElse newValue" ]]
}

function Options::generateOption::caseStringArray1::OptionTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray1.sh"
  run Options::optionVarName help
  assert_lines_count 2
  assert_line --index 0 --partial "  --var (optional)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseStringArray2Success ensures
# that testsData/generateOption.caseStringArray2.sh is up to date
# Case 2: 2 --alt
function Options::generateOption::caseStringArray2::success { #@test
  run Options::generateOption --type StringArray --variable-name "varName" --alt "--var" --alt "-v"
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
  diff "${tmpFile}" "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray2.sh" >&3 || {
    cat "${tmpFile}" >&3
    return 1
  }
}

function Options::generateOption::caseStringArray2::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray2.sh"
  run Options::optionVarName
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Option command invalid: ''"
}

function Options::generateOption::caseStringArray2::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray2.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "1" ]]
  [[ "${varName[*]}" = "somethingElse" ]]
}

function Options::generateOption::caseStringArray2::OptionsTest::parseWithArgAlt1 { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray2.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse --var "newValue" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "2" ]]
  [[ "${varName[*]}" = "somethingElse newValue" ]]
}

function Options::generateOption::caseStringArray2::OptionsTest::parseWithArgAlt2 { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray2.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse -v "newValue" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "2" ]]
  [[ "${varName[*]}" = "somethingElse newValue" ]]
}

function Options::generateOption::caseStringArray2::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray2.sh"
  run Options::optionVarName help
  assert_lines_count 2
  assert_line --index 0 --partial "  --var, -v (optional)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseStringArray4 ensures
# that testsData/generateOption.caseStringArray3.sh is up to date
# Case 3: 2 --alt + mandatory
function Options::generateOption::caseStringArray3::success { #@test
  run Options::generateOption --type StringArray --variable-name "varName" \
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
  diff "${tmpFile}" "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray3.sh" >&3 || {
    cat "${tmpFile}" >&3
    return 1
  }
}

function Options::generateOption::caseStringArray3::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray3.sh"
  run Options::optionVarName
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Option command invalid: ''"
}

function Options::generateOption::caseStringArray3::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray3.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Option '--var' should be provided at least 1 time(s)"
  [[ "${#varName[@]}" = "1" ]]
  [[ "${varName[*]}" = "somethingElse" ]]
}

function Options::generateOption::caseStringArray3::OptionsTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray3.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse --var NewValue >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "2" ]]
  [[ "${varName[*]}" = "somethingElse NewValue" ]]
}

function Options::generateOption::caseStringArray3::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray3.sh"
  run Options::optionVarName help
  assert_lines_count 2
  assert_line --index 0 --partial "  --var, -v (at least 1 times)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseStringArray4 ensures
# that testsData/generateOption.caseStringArray4.sh is up to date
# Case 3: 2 --alt + mandatory + custom help
function Options::generateOption::caseStringArray4::success { #@test
  run Options::generateOption --type StringArray --variable-name "varName" \
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
  diff "${tmpFile}" "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray4.sh" >&3 || {
    cat "${tmpFile}" >&3
    return 1
  }
}

function Options::generateOption::caseStringArray4::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray4.sh"
  run Options::optionVarName
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Option command invalid: ''"
}

function Options::generateOption::caseStringArray4::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray4.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Option '--var' should be provided"
  [[ "${#varName[@]}" = "1" ]]
  [[ "${varName[*]}" = "somethingElse" ]]
}

function Options::generateOption::caseStringArray4::OptionsTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray4.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse --var "NewValue" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "2" ]]
  [[ "${varName[*]}" = "somethingElse NewValue" ]]
}

function Options::generateOption::caseStringArray4::OptionsTest::parseMultipleArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray4.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse --var "NewValue" -v "NewValue2" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "3" ]]
  [[ "${varName[*]}" = "somethingElse NewValue NewValue2" ]]
}

function Options::generateOption::caseStringArray4::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray4.sh"
  run Options::optionVarName help
  assert_lines_count 2
  assert_line --index 0 --partial "  --var, -v (at least 1 times)"
  assert_line --index 1 "    super help"
}

# Options::generateOption::caseStringArray4 ensures
# that testsData/generateOption.caseStringArray4.sh is up to date
# Case 5: 2 --alt + min 2 + max 3 + custom help + --authorized-values
function Options::generateOption::caseStringArray5::success { #@test
  run Options::generateOption --type StringArray --variable-name "varName" \
    --alt "--var" --alt "-v" --min 2 --max 3 --authorized-values "value1|value2|value3" --help "super help"
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
  diff "${tmpFile}" "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray5.sh" >&3 || {
    cat "${tmpFile}" >&3
    return 1
  }
}

function Options::generateOption::caseStringArray5::OptionsTest::parseWithNotEnoughArgs { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray5.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse --var "value1" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Option '--var' should be provided at least 2 time(s)"
  [[ "${#varName[@]}" = "2" ]]
  [[ "${varName[*]}" = "somethingElse value1" ]]
}

function Options::generateOption::caseStringArray5::OptionsTest::parseWithArgInvalid { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray5.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse --var "NewValue" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Option --var - value 'NewValue' is not part of authorized values(value1|value2|value3)"
  [[ "${#varName[@]}" = "1" ]]
  [[ "${varName[*]}" = "somethingElse" ]]
}

function Options::generateOption::caseStringArray5::OptionsTest::parseMultipleArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray5.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse --var "value1" -v "value2" -v "value3" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "4" ]]
  [[ "${varName[*]}" = "somethingElse value1 value2 value3" ]]
}

function Options::generateOption::caseStringArray5::OptionsTest::parseWithTooMuchArgs { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray5.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::optionVarName parse --var "value1" -v "value2" -v "value3" -v "value3" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Option -v - Maximum number of option occurrences reached(3)"
  [[ "${#varName[@]}" = "4" ]]
  [[ "${varName[*]}" = "somethingElse value1 value2 value3" ]]
}

function Options::generateOption::caseStringArray5::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray5.sh"
  run Options::optionVarName help
  assert_lines_count 2
  assert_line --index 0 --partial "  --var, -v (at least 2 times) (at most 3 times)"
  assert_line --index 1 "    super help"
}
