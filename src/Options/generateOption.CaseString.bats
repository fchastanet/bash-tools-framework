#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Options/_bats.sh
source "${srcDir}/Options/_bats.sh"

# shellcheck source=src/Options/__all.sh
source "${srcDir}/Options/__all.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
}

# Options::generateOption::caseString1::Success ensures
# that testsData/generateOption.caseString1.sh is up to date
# Case 1: 1 --alt
function Options::generateOption::caseString1::success { #@test
  local status=0
  Options::generateOption --type String --variable-name "varName" --alt "--var" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseString1.sh" "Options::optionVarName"
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
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var <String>${__HELP_NORMAL} (optional) (at most 1 times)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseString2Success ensures
# that testsData/generateOption.caseString2.sh is up to date
# Case 2: 2 --alt
function Options::generateOption::caseString2::success { #@test
  local status=0
  Options::generateOption --type String --variable-name "varName" --alt "--var" --alt "-v" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseString2.sh" "Options::optionVarName"
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
  run eval Options::optionVarName help
  assert_lines_count 2
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var, -v <String>${__HELP_NORMAL} (optional) (at most 1 times)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseString4 ensures
# that testsData/generateOption.caseString3.sh is up to date
# Case 3: 2 --alt + mandatory
function Options::generateOption::caseString3::success { #@test
  local status=0
  Options::generateOption --type String --variable-name "varName" \
    --alt "--var" --alt "-v" --mandatory \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseString3.sh" "Options::optionVarName"
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
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var, -v <String>${__HELP_NORMAL} (mandatory)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseString4 ensures
# that testsData/generateOption.caseString4.sh is up to date
# Case 3: 2 --alt + mandatory + custom help
function Options::generateOption::caseString4::success { #@test
  local status=0
  Options::generateOption --type String --variable-name "varName" \
    --alt "--var" --alt "-v" --mandatory --help "super help" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseString4.sh" "Options::optionVarName"
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
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var, -v <String>${__HELP_NORMAL} (mandatory)"
  assert_line --index 1 "    super help"
}
