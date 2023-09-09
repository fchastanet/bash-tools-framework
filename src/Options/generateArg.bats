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

function Options::generateArg::noOption { #@test
  run Options::generateArg
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --variable-name is mandatory"
}

function Options::generateArg::invalidOption { #@test
  run Options::generateArg --invalid
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --invalid - invalid option provided"
}

function Options::generateArg::checkOption::var::noValueProvided { #@test
  run Options::generateArg --var
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --var - a value needs to be specified"
}

function Options::generateArg::checkOption::help::noValueProvided { #@test
  run Options::generateArg --help
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --help - a value needs to be specified"
}

function Options::generateArg::checkOption::name::noValueProvided { #@test
  run Options::generateArg --name
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --name - a value needs to be specified"
}

function Options::generateArg::checkOption::authorizedValues::noValueProvided { #@test
  run Options::generateArg --authorized-values
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --authorized-values - a value needs to be specified"
}

function Options::generateArg::checkOption::regexp::noValueProvided { #@test
  run Options::generateArg --regexp
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --regexp - a value needs to be specified"
}

function Options::generateArg::checkOption::var::emptyValueProvided { #@test
  run Options::generateArg --var ""
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - invalid variable name"
}

function Options::generateArg::checkOption::var::optionTwice { #@test
  run Options::generateArg --var "var" --var "var"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --var - can be provided once"
}

function Options::generateArg::checkOption::help::optionTwice { #@test
  run Options::generateArg --help "help" --help "help"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --help - can be provided once"
}

function Options::generateArg::checkOption::name::optionTwice { #@test
  run Options::generateArg --name "name" --name "name"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --name - can be provided once"
}

function Options::generateArg::checkOption::authorizedValues::optionTwice { #@test
  run Options::generateArg --authorized-values "a|b" --authorized-values "a|b"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --authorized-values - can be provided once"
}

function Options::generateArg::checkOption::regexp::optionTwice { #@test
  run Options::generateArg --regexp "^$" --regexp "^$"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --regexp - can be provided once"
}

function Options::generateArg::checkOption::var::invalid { #@test
  run Options::generateArg --var "François"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - invalid variable name François"
}

function Options::generateArg::checkOption::min::invalidValue { #@test
  run Options::generateArg --min "François"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --min - should be an int >= 0"
}

function Options::generateArg::checkOption::min::invalidIntValue { #@test
  run Options::generateArg --min -1
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --min - should be an int >= 0"
}

function Options::generateArg::checkOption::max::invalidValue { #@test
  run Options::generateArg --max "François"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --max - should be an int >=0 or -1(infinite)"
}

function Options::generateArg::checkOption::max::invalidIntValue { #@test
  run Options::generateArg --max -2
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --max - should be an int >=0 or -1(infinite)"
}

function Options::generateArg::checkOption::authorizedValues::invalidValue { #@test
  run Options::generateArg --authorized-values "a b"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --authorized-values - invalid regexp 'a b'"
}

function Options::generateArg::checkOption::regexp::invalidValue { #@test
  run Options::generateArg --regexp "a b"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --regexp - invalid regexp 'a b'"
}

function Options::generateArg::checkOption::min-max::mismatch1 { #@test
  run Options::generateArg --var name --min 2 --max 1
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateArg - Option --min cannot be greater than --max option"
}

# case 1 : simple varName mandatory argument
function Options::generateArg::checkOption::success:case1 { #@test
  local status=0
  Options::generateArg --variable-name "varName" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateArg.case1.sh" "Options::arg"
}

function Options::generateArg::case1::ArgTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case1.sh"
  run Options::arg
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Argument command invalid: ''"
}

function Options::generateArg::case1::ArgTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case1.sh"
  local status=0
  local varName="somethingElse"
  Options::arg parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Argument 'varName' should be provided at least 1 time(s)"
  [[ "${varName}" = "somethingElse" ]]
}

function Options::generateArg::case1::ArgTest::parseWithOption { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case1.sh"
  local status=0
  local varName="somethingElse"
  Options::arg parse --var >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Argument 'varName' should be provided at least 1 time(s)"
  [[ "${varName}" = "somethingElse" ]]
}

function Options::generateArg::case1::ArgTest::parseWithArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case1.sh"
  local status=0
  local varName="somethingElse"
  Options::arg parse "Argument" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName}" = "Argument" ]]
}

function Options::generateArg::case1::ArgTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case1.sh"
  run Options::arg help
  assert_lines_count 2
  assert_line --index 0 "  $(echo -e "${__HELP_OPTION_COLOR}")varName${__HELP_NORMAL} {single} (mandatory)"
  assert_line --index 1 "    No help available"
}

function Options::generateArg::case1::ArgTest::otherCommands { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case1.sh"
  run Options::arg variableName
  assert_success
  assert_output "varName"

  run Options::arg type
  assert_success
  assert_output "Argument"

  run Options::arg variableType
  assert_success
  assert_output "String"

  run Options::arg min
  assert_success
  assert_output "1"

  run Options::arg max
  assert_success
  assert_output "1"

  run Options::arg helpArg
  assert_success
  assert_output "varName {single} (mandatory)"

  run Options::arg oneLineHelp
  assert_success
  assert_output "Argument varName min 1 max 1 authorizedValues '' regexp ''"

  local status=0
  Options::arg export >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${type}" = "Argument" ]]
  [[ "${variableType}" = "String" ]]
  [[ "${variableName}" = "varName" ]]
  [[ "${name}" = "varName" ]]
  [[ "${min}" = "1" ]]
  [[ "${max}" = "1" ]]
  [[ "${authorizedValues}" = "" ]]
  [[ "${regexp}" = "" ]]
}

# case 2 : varName min=0, max=3, authorizedValues=debug|info|warn
function Options::generateArg::checkOption::success:case2 { #@test
  local status=0
  Options::generateArg \
    --variable-name "varName" \
    --min 0 \
    --max 3 \
    --authorized-values "debug|info|warn" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateArg.case2.sh" "Options::arg"
}

function Options::generateArg::case2::ArgTest::noArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case2.sh"
  run Options::arg
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Argument command invalid: ''"
}

function Options::generateArg::case2::ArgTest::parseWithNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case2.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::arg parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName[*]}" = "somethingElse" ]]
}

function Options::generateArg::case2::ArgTest::parseWithOption { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case2.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::arg parse --var >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName[*]}" = "somethingElse" ]]
}

function Options::generateArg::case2::ArgTest::parseWithArgInvalid { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case2.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::arg parse "Argument" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Argument varName - value 'Argument' is not part of authorized values(debug|info|warn)"
  [[ "${varName[*]}" = "somethingElse" ]]
}

function Options::generateArg::case2::ArgTest::parseWithArgValid { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case2.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::arg parse "debug" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName[*]}" = "somethingElse debug" ]]
}

function Options::generateArg::case2::ArgTest::parseWith3ArgsValid { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case2.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::arg parse "debug" "info" "warn" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  [[ "${varName[*]}" = "somethingElse debug info warn" ]]
}

function Options::generateArg::case2::ArgTest::parseWith4ArgsValid { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case2.sh"
  local status=0
  local -a varName=("somethingElse")
  Options::arg parse "debug" "info" "warn" "info" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Command test - Argument varName - Maximum number of argument occurrences reached(3)"
  [[ "${varName[*]}" = "somethingElse debug info warn" ]]
}

function Options::generateArg::case2::ArgTest::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateArg.case2.sh"
  run Options::arg help
  assert_lines_count 2
  assert_line --index 0 "  $(echo -e "[${__HELP_OPTION_COLOR}")varName${__HELP_NORMAL} {list} (at most 3 times)]"
  assert_line --index 1 "    No help available"
}
