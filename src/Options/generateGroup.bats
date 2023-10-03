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

function Options::generateGroup::noOption { #@test
  run Options::generateGroup
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateGroup - option --title is mandatory"
}

function Options::generateGroup::missingValue { #@test
  run Options::generateGroup --title
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateGroup - Option --title - a value needs to be specified"
}

function Options::generateGroup::missingHelpOption { #@test
  run Options::generateGroup --title "Global options" --help
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateGroup - Option --help - a value needs to be specified"
}

function Options::generateGroup::titleOptionTwice { #@test
  run Options::generateGroup --title "Global options" --title "Global options2"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateGroup - only one --title option can be provided"
}

function Options::generateGroup::helpOptionTwice { #@test
  run Options::generateGroup --title "Global options" --help "help1" --help "help2"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateGroup - only one --help option can be provided"
}

function Options::generateOption::groupOptionValid { #@test
  local status=0
  Options::generateGroup --title "Global options" --help "help" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateGroup.caseGroupOptionValid.sh" "Options::group"
  source "${BATS_TEST_DIRNAME}/testsData/generateGroup.caseGroupOptionValid.sh"
  run Options::group help
  assert_line --index 0 "$(echo -e "${__HELP_TITLE_COLOR}Global options${__RESET_COLOR}")"
  assert_line --index 1 "help"
  run Options::group id
  assert_output "Options::group"
}
