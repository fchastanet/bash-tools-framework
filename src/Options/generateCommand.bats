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

function Options::generateCommand::noOption { #@test
  run Options::generateCommand
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - at least one option must be provided as positional argument"
}

function Options::generateCommand::invalidArgument { #@test
  run Options::generateCommand --invalid
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - invalid option provided '--invalid'"
}

function Options::generateCommand::helpMissingValue { #@test
  run Options::generateCommand --help
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - Option --help - a value needs to be specified"
}

function Options::generateCommand::versionMissingValue { #@test
  run Options::generateCommand --version
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - Option --version - a value needs to be specified"
}

function Options::generateCommand::authorMissingValue { #@test
  run Options::generateCommand --author
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - Option --author - a value needs to be specified"
}

function Options::generateCommand::commandNameMissingValue { #@test
  run Options::generateCommand --command-name
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - Option --command-name - a value needs to be specified"
}

function Options::generateCommand::licenseMissingValue { #@test
  run Options::generateCommand --license
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - Option --license - a value needs to be specified"
}

function Options::generateCommand::copyrightMissingValue { #@test
  run Options::generateCommand --copyright
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - Option --copyright - a value needs to be specified"
}

function Options::generateCommand::helpTemplateMissingValue { #@test
  run Options::generateCommand --help-template
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - Option --help-template - a value needs to be specified"
}

function Options::generateCommand::invalidPositionalArg { #@test
  run Options::generateCommand --help-template "help.tpl" "positionalArg" --version "version 1.0"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - only function type are accepted as positional argument - invalid 'positionalArg'"
}

function Options::generateCommand::atLeastOnePositionalArg { #@test
  run Options::generateCommand --help-template "help.tpl" --version "version 1.0"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - at least one option must be provided as positional argument"
}

function Options::generateCommand::case1 { #@test
  Options::myCustomOption() {
    if [[ "$1" = "help" ]]; then
      echo "help"
    fi
    if [[ "$1" = "helpAlt" ]]; then
      echo "helpAlt"
    fi
  }
  local status=0
  Options::generateCommand Options::myCustomOption >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  testCommand "generateCommand.case1.sh" "Options::command"
}

function Options::generateCommand::case1::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case1.sh"
  run Options::command help
  checkCommandResult "generateCommand.case1.expected.help"
}

function Options::generateCommand::case2 { #@test
  local optionVerbose
  optionVerbose="$(Options::generateOption --help "verbose mode" \
    --variable-name "verbose" --alt "--verbose" --alt "-v")" || return 1
  sourceOption "${optionVerbose}"

  local status=0
  Options::generateCommand --help "super command" ${optionVerbose} >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  testCommand "generateCommand.case2.sh" "Options::command"
}

function Options::generateCommand::case2::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case2.sh"
  run Options::command help
  checkCommandResult "generateCommand.case2.expected.help"
}

function Options::generateCommand::case3 { #@test
  local optionVerbose
  optionVerbose="$(Options::generateOption --help "verbose mode" \
    --variable-name "verbose" --alt "--verbose" --alt "-v")" || return 1
  sourceOption "${optionVerbose}"

  local optionSrcDirs
  optionSrcDirs="$(Options::generateOption --type StringArray \
    --help "provide the directory where to find the functions source code." \
    --variable-name "srcDirs" --alt "--src-dirs" --alt "-s")" || return 1
  sourceOption "${optionSrcDirs}"

  local status=0
  Options::generateCommand --help "super command" \
    ${optionVerbose} \
    ${optionSrcDirs} \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  testCommand "generateCommand.case3.sh" "Options::command"
}

function Options::generateCommand::case3::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case3.sh"
  run Options::command help
  checkCommandResult "generateCommand.case3.expected.help"
}

# TODO case with arguments function
