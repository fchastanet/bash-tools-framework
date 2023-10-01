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

# Options::generateOption::caseBoolean1Success ensures
# that testsData/generateOption.caseBoolean2.sh is up to date
# Case 1: 1 --alt
function Options::generateOption::caseBoolean1::success { #@test
  local status=0
  Options::generateOption --variable-name "varName" --alt "--var" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseBoolean1.sh" "Options::option"
}

function Options::generateOption::caseBoolean1::otherCommands { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean1.sh"
  run Options::option variableName
  assert_success
  assert_output "varName"

  run Options::option type
  assert_success
  assert_output "Option"

  run Options::option variableType
  assert_success
  assert_output "Boolean"

  run Options::option helpAlt
  assert_success
  assert_output "[--var]"

  run Options::option oneLineHelp
  assert_success
  assert_output "Option varName --var variableType Boolean min 0 max 1 authorizedValues '' regexp ''"

  local status=0
  Options::option export >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${type}" = "Option" ]]
  [[ "${variableType}" = "Boolean" ]]
  [[ "${variableName}" = "varName" ]]
  [[ "${onValue}" = "1" ]]
  [[ "${offValue}" = "0" ]]
  [[ "${defaultValue}" = "" ]]
  [[ "${min}" = "0" ]]
  [[ "${max}" = "1" ]]
  [[ "${authorizedValues}" = "" ]]
  [[ "${alts}" = "--var" ]]
}

function Options::generateOption::caseBoolean1::OptionTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean1.sh"
  run Options::option
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option command invalid: ''"
}

function Options::generateOption::caseBoolean1::OptionTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean1.sh"
  local status=0
  local varName="somethingElse"
  Options::option parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "0" ]]
}

function Options::generateOption::caseBoolean1::OptionTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean1.sh"
  local status=0
  local varName="somethingElse"
  Options::option parse --var >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "1" ]]
}

function Options::generateOption::caseBoolean1::OptionTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean1.sh"
  run Options::option help
  assert_lines_count 2
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var${__HELP_NORMAL} (optional) (at most 1 times)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseBoolean2Success ensures
# that testsData/generateOption.caseBoolean2.sh is up to date
# Case 2: 2 --alt
function Options::generateOption::caseBoolean2::success { #@test
  local status=0
  Options::generateOption --variable-name "varName" --alt "--var" --alt "-v" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseBoolean2.sh" "Options::option"
}

function Options::generateOption::caseBoolean2::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean2.sh"
  run Options::option
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option command invalid: ''"
}

function Options::generateOption::caseBoolean2::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean2.sh"
  local status=0
  local varName="somethingElse"
  Options::option parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "0" ]]
}

function Options::generateOption::caseBoolean2::OptionsTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean2.sh"
  local status=0
  local varName="somethingElse"
  Options::option parse --var >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "1" ]]
}

function Options::generateOption::caseBoolean2::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean2.sh"
  run Options::option help
  assert_lines_count 2
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var, -v${__HELP_NORMAL} (optional) (at most 1 times)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseBoolean4 ensures
# that testsData/generateOption.caseBoolean3.sh is up to date
# Case 3: 2 --alt + mandatory
function Options::generateOption::caseBoolean3::success { #@test
  local status=0
  Options::generateOption --variable-name "varName" \
    --alt "--var" --alt "-v" --mandatory \
    >"${BATS_TEST_TMPDIR}/result" 2>"${BATS_TEST_TMPDIR}/error" || status=$?
  testCommand "generateOption.caseBoolean3.sh" "Options::option"
  run cat "${BATS_TEST_TMPDIR}/error"
  assert_lines_count 1
  assert_output --partial 'SKIPPED - Options::generateOptionBoolean - --mandatory is incompatible with Boolean type, ignored'
}

function Options::generateOption::caseBoolean3::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean3.sh"
  run Options::option
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option command invalid: ''"
}

function Options::generateOption::caseBoolean3::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean3.sh"
  local status=0
  local varName="somethingElse"
  Options::option parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "0" ]]
}

function Options::generateOption::caseBoolean3::OptionsTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean3.sh"
  local status=0
  local varName="somethingElse"
  Options::option parse --var >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "1" ]]
}

function Options::generateOption::caseBoolean3::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean3.sh"
  run Options::option help
  assert_lines_count 2
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var, -v${__HELP_NORMAL} (optional) (at most 1 times)"
  assert_line --index 1 "    No help available"
}

# Options::generateOption::caseBoolean4 ensures
# that testsData/generateOption.caseBoolean4.sh is up to date
# Case 4: 2 --alt + mandatory + custom help
function Options::generateOption::caseBoolean4::success { #@test
  local status=0
  Options::generateOption --variable-name "varName" \
    --alt "--var" --alt "-v" --mandatory --help "super help" \
    >"${BATS_TEST_TMPDIR}/result" 2>"${BATS_TEST_TMPDIR}/error" || status=$?
  testCommand "generateOption.caseBoolean4.sh" "Options::option"
  run cat "${BATS_TEST_TMPDIR}/error"
  assert_lines_count 1
  assert_output --partial 'SKIPPED - Options::generateOptionBoolean - --mandatory is incompatible with Boolean type, ignored'
}

function Options::generateOption::caseBoolean4::OptionsTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean4.sh"
  run Options::option
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Option command invalid: ''"
}

function Options::generateOption::caseBoolean4::OptionsTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean4.sh"
  local status=0
  local varName="somethingElse"
  Options::option parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "0" ]]
}

function Options::generateOption::caseBoolean4::OptionsTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean4.sh"
  local status=0
  local varName="somethingElse"
  Options::option parse --var >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "1" ]]
}

function Options::generateOption::caseBoolean4::OptionsTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean4.sh"
  run Options::option help
  assert_lines_count 2
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")--var, -v${__HELP_NORMAL} (optional) (at most 1 times)"
  assert_line --index 1 "    super help"
}

# Options::generateOption::caseBoolean5 ensures
# that testsData/generateOption.caseBoolean5.sh is up to date
# Case 5: callback
function Options::generateOption::caseBoolean5::success { #@test
  local status=0
  function helpCallback() {
    :
  }
  function helpCallback2() {
    :
  }
  Options::generateOption --variable-name "help" \
    --alt "--help" --alt "-h" --callback helpCallback --callback helpCallback2 \
    >"${BATS_TEST_TMPDIR}/result" 2>"${BATS_TEST_TMPDIR}/error" || status=$?
  testCommand "generateOption.caseBoolean5.sh" "Options::option"
  run cat "${BATS_TEST_TMPDIR}/error"
  assert_output ""
}

function Options::generateOption::caseBoolean5::OptionsTest::parseHelp { #@test
  function helpCallback() {
    echo "helpCallback called $*"
  }
  function helpCallback2() {
    echo "helpCallback2 called $*"
  }
  source "${BATS_TEST_DIRNAME}/testsData/generateOption.caseBoolean5.sh"
  local status=0
  Options::option parse --help >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "helpCallback called --help"
  assert_line --index 1 "helpCallback2 called --help"
}
