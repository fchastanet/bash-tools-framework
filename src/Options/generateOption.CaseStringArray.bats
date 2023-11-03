#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Options/_bats.sh
source "${srcDir}/Options/_bats.sh"

# shellcheck source=src/Options/__all.sh
source "${srcDir}/Options/__all.sh"
# shellcheck source=src/Filters/removeAnsiCodes.sh
source "${srcDir}/Filters/removeAnsiCodes.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
}

# Options::generateOption::caseStringArray1::Success ensures
# that testsData/generateOption.caseStringArray1.sh is up to date
# Case 1: 1 --alt
function Options::generateOption::caseStringArray1::success { #@test
  local status=0
  Options::generateOption --variable-type StringArray --variable-name "varName" --alt "--var" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseStringArray1.sh" "Options::option"
}

function Options::generateOption::caseStringArray1::OptionTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray1.sh"
  run Options::option
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option command invalid: ''"
}

function Options::generateOption::caseStringArray1::OptionTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray1.sh"
  local status=0
  local -a varName=()
  Options::option parse --var >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option --var - a value needs to be specified"
  [[ "${#varName[@]}" = "0" ]]
}

function Options::generateOption::caseStringArray1::OptionTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray1.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::option parse --var newValue >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "2" ]]
  [[ "${varName[*]}" = "somethingElse newValue" ]]
}

function Options::generateOption::caseStringArray1::OptionTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray1.sh"
  run Options::option help
  assert_lines_count 2
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var <String>${__HELP_NORMAL} {list} (optional)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseStringArray2Success ensures
# that testsData/generateOption.caseStringArray2.sh is up to date
# Case 2: 2 --alt
function Options::generateOption::caseStringArray2::success { #@test
  local status=0
  Options::generateOption --variable-type StringArray --variable-name "varName" --alt "--var" --alt "-v" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseStringArray2.sh" "Options::option"
}

function Options::generateOption::caseStringArray2::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray2.sh"
  run Options::option
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option command invalid: ''"
}

function Options::generateOption::caseStringArray2::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray2.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::option parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
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
  Options::option parse --var "newValue" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
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
  Options::option parse -v "newValue" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "2" ]]
  [[ "${varName[*]}" = "somethingElse newValue" ]]
}

function Options::generateOption::caseStringArray2::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray2.sh"
  run Options::option help
  assert_lines_count 2
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var${__HELP_NORMAL}, $(echo -e "${__HELP_OPTION_COLOR}")-v <String>${__HELP_NORMAL} {list} (optional)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseStringArray4 ensures
# that testsData/generateOption.caseStringArray3.sh is up to date
# Case 3: 2 --alt + mandatory
function Options::generateOption::caseStringArray3::success { #@test
  local status=0
  Options::generateOption --variable-type StringArray --variable-name "varName" \
    --alt "--var" --alt "-v" --mandatory \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseStringArray3.sh" "Options::option"
}

function Options::generateOption::caseStringArray3::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray3.sh"
  run Options::option
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option command invalid: ''"
}

function Options::generateOption::caseStringArray3::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray3.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::option parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option '--var' should be provided at least 1 time(s)"
  [[ "${#varName[@]}" = "1" ]]
  [[ "${varName[*]}" = "somethingElse" ]]
}

function Options::generateOption::caseStringArray3::OptionsTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray3.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::option parse --var NewValue >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "2" ]]
  [[ "${varName[*]}" = "somethingElse NewValue" ]]
}

function Options::generateOption::caseStringArray3::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray3.sh"
  run Options::option help
  assert_lines_count 2
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var${__HELP_NORMAL}, $(echo -e "${__HELP_OPTION_COLOR}")-v <String>${__HELP_NORMAL} {list} (at least 1 times)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseStringArray4 ensures
# that testsData/generateOption.caseStringArray4.sh is up to date
# Case 3: 2 --alt + mandatory + custom help
function Options::generateOption::caseStringArray4::success { #@test
  local status=0
  Options::generateOption --variable-type StringArray --variable-name "varName" \
    --alt "--var" --alt "-v" --mandatory --help "super help" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseStringArray4.sh" "Options::option"
}

function Options::generateOption::caseStringArray4::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray4.sh"
  run Options::option
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option command invalid: ''"
}

function Options::generateOption::caseStringArray4::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray4.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::option parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option '--var' should be provided"
  [[ "${#varName[@]}" = "1" ]]
  [[ "${varName[*]}" = "somethingElse" ]]
}

function Options::generateOption::caseStringArray4::OptionsTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray4.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::option parse --var "NewValue" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
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
  Options::option parse --var "NewValue" -v "NewValue2" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${#varName[@]}" = "3" ]]
  [[ "${varName[*]}" = "somethingElse NewValue NewValue2" ]]
}

function Options::generateOption::caseStringArray4::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray4.sh"
  run Options::option help
  assert_lines_count 2
  assert_line --index 0 "$(echo -e "  ${__HELP_OPTION_COLOR}--var${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-v <String>${__HELP_NORMAL} {list} (at least 1 times)")"
  assert_line --index 1 "    super help"
}

# Options::generateOption::caseStringArray4 ensures
# that testsData/generateOption.caseStringArray4.sh is up to date
# Case 5: 2 --alt + min 2 + max 3 + custom help + --authorized-values
function Options::generateOption::caseStringArray5::success { #@test
  local status=0
  Options::generateOption --variable-type StringArray --variable-name "varName" \
    --alt "--var" --alt "-v" --min 2 --max 3 --authorized-values "value1|value2|value3" \
    --help "super help" --help-value-name "myVarName" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseStringArray5.sh" "Options::option"
}

function Options::generateOption::caseStringArray5::otherCommands { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray5.sh"
  run Options::option variableName
  assert_success
  assert_output "varName"

  run Options::option type
  assert_success
  assert_output "Option"

  run Options::option variableType
  assert_success
  assert_output "StringArray"

  run Options::option helpAlt
  assert_success
  assert_output "--var|-v <myVarName>"

  run Options::option oneLineHelp
  assert_success
  assert_output "Option varName --var|-v variableType StringArray min 2 max 3 authorizedValues 'value1|value2|value3' regexp ''"

  local status=0
  Options::option export >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${type}" = "Option" ]]
  [[ "${variableType}" = "StringArray" ]]
  [[ "${variableName}" = "varName" ]]
  [[ "${onValue}" = "" ]]
  [[ "${offValue}" = "" ]]
  [[ "${defaultValue}" = "" ]]
  [[ "${min}" = "2" ]]
  [[ "${max}" = "3" ]]
  [[ "${authorizedValues}" = "value1|value2|value3" ]]
  [[ "${alts[*]}" = "--var -v" ]]
}

function Options::generateOption::caseStringArray5::OptionsTest::parseWithNotEnoughArgs { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray5.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::option parse --var "value1" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option '--var' should be provided at least 2 time(s)"
  [[ "${#varName[@]}" = "2" ]]
  [[ "${varName[*]}" = "somethingElse value1" ]]
}

function Options::generateOption::caseStringArray5::OptionsTest::parseWithArgInvalid { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray5.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::option parse --var "NewValue" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option --var - value 'NewValue' is not part of authorized values(value1|value2|value3)"
  [[ "${#varName[@]}" = "1" ]]
  [[ "${varName[*]}" = "somethingElse" ]]
}

function Options::generateOption::caseStringArray5::OptionsTest::parseMultipleArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray5.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::option parse --var "value1" -v "value2" -v "value3" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
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
  Options::option parse --var "value1" -v "value2" -v "value3" -v "value3" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option -v - Maximum number of option occurrences reached(3)"
  [[ "${#varName[@]}" = "4" ]]
  [[ "${varName[*]}" = "somethingElse value1 value2 value3" ]]
}

function Options::generateOption::caseStringArray5::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray5.sh"
  run Options::option help
  assert_lines_count 2
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var${__HELP_NORMAL}, $(echo -e "${__HELP_OPTION_COLOR}")-v <myVarName>${__HELP_NORMAL} {list} (at least 2 times) (at most 3 times)"
  assert_line --index 1 "    super help"
}

# Options::generateOption::caseStringArray6 ensures
# that testsData/generateOption.caseStringArray6.sh is up to date
# Case 6: callback
function Options::generateOption::caseStringArray6::success { #@test
  local status=0
  function srcDirsCallback() {
    :
  }
  Options::generateOption --variable-type StringArray --variable-name "srcDirs" \
    --alt "--src-dir" --alt "-s" --max -1 --callback srcDirsCallback \
    >"${BATS_TEST_TMPDIR}/result" 2>"${BATS_TEST_TMPDIR}/error" || status=$?
  testCommand "generateOption.caseStringArray6.sh" "Options::option"
  run cat "${BATS_TEST_TMPDIR}/error"
  assert_output ""
}

function Options::generateOption::caseStringArray6::OptionsTest::parseSrcDirs { #@test
  function srcDirsCallback() {
    echo "srcDirsCallback called $*"
  }
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseStringArray6.sh"
  local status=0
  local -a srcDirs=()
  Options::option parse --src-dir test1 -s test2 >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "srcDirsCallback called --src-dir test1"
  assert_line --index 1 "srcDirsCallback called -s test1 test2"
}
