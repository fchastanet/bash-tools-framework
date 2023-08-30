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
  assert_output --partial "ERROR   - Options::generateCommand - at least one option or argument must be provided as positional argument"
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
  assert_output --partial "ERROR   - Options::generateCommand - at least one option or argument must be provided as positional argument"
}

function Options::generateCommand::case1 { #@test
  local optionFile
  optionFile="$(Options::generateOption --variable-type String --help "file" \
    --variable-name "file" --alt "--file" --alt "-f")" || return 1
  sourceFunctionFile "${optionFile}"

  local status=0
  Options::generateCommand --help "super command" ${optionFile} >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  testCommand "generateCommand.case1.sh" "Options::command"
}

function Options::generateCommand::case1::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case1.sh"
  run Options::command help
  checkCommandResult "generateCommand.case1.expected.help"
}

function Options::generateCommand::case1::parseNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case1.sh"
  local status=0
  local file="fileBefore"
  Options::command parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${file}" = "fileBefore" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Options::generateCommand::case1::missingFile { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case1.sh"
  local status=0
  local file="fileBefore"
  Options::command parse --file >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "${file}" = "fileBefore" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Option --file - a value needs to be specified"
}

function Options::generateCommand::case1::parseFile { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case1.sh"
  local status=0
  local file="fileBefore"
  Options::command parse --file fileTest >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${file}" = "fileTest" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Options::generateCommand::case2 { #@test
  local optionVerbose
  optionVerbose="$(Options::generateOption --help "verbose mode" \
    --variable-name "verbose" --alt "--verbose" --alt "-v")" || return 1
  sourceFunctionFile "${optionVerbose}"

  local status=0
  Options::generateCommand --no-error-if-unknown-option \
    --help "super command" ${optionVerbose} >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  testCommand "generateCommand.case2.sh" "Options::command"
}

function Options::generateCommand::case2::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case2.sh"
  run Options::command help
  checkCommandResult "generateCommand.case2.expected.help"
}

function Options::generateCommand::case2::parseNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case2.sh"
  local status=0
  local verbose
  Options::command parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${verbose}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Options::generateCommand::case2::parseVerbose { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case2.sh"
  local status=0
  local verbose
  Options::command parse --verbose >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${verbose}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Options::generateCommand::case2::parseInvalidOption { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case2.sh"
  local status=0
  local verbose
  Options::command parse --invalid-option >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${verbose}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Options::generateCommand::case3 { #@test
  local optionVerbose
  optionVerbose="$(Options::generateOption --help "verbose mode" \
    --variable-name "verbose" --alt "--verbose" --alt "-v")" || return 1
  sourceFunctionFile "${optionVerbose}"

  local optionSrcDirs
  optionSrcDirs="$(Options::generateOption --variable-type StringArray \
    --help "provide the directory where to find the functions source code." \
    --variable-name "srcDirs" --alt "--src-dirs" --alt "-s")" || return 1
  sourceFunctionFile "${optionSrcDirs}"

  local optionSrcDirs
  optionSrcDirs="$(Options::generateOption --variable-type StringArray \
    --help "provide the directory where to find the functions source code." \
    --variable-name "srcDirs" --alt "--src-dirs" --alt "-s")" || return 1
  sourceFunctionFile "${optionSrcDirs}"

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

function Options::generateCommand::case3::parseNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case3.sh"
  local status=0
  local verbose
  local -a srcDirs=("initialDir")
  Options::command parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${verbose}" = "0" ]]
  [[ "${srcDirs[*]}" = "initialDir" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Options::generateCommand::case3::parseInvalidOption { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case3.sh"
  local status=0
  local verbose
  local -a srcDirs=("initialDir")
  Options::command parse --invalid-option >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "${verbose}" = "0" ]]
  [[ "${srcDirs[*]}" = "initialDir" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Invalid option --invalid-option"
}

function Options::generateCommand::case3::parseAll { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case3.sh"
  local status=0
  local verbose
  local -a srcDirs=("initialDir")
  Options::command parse --verbose --src-dirs srcDir1 -s srcDir2 >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${verbose}" = "1" ]]
  [[ "${srcDirs[*]}" = "initialDir srcDir1 srcDir2" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Options::generateCommand::case4 { #@test
  local optionVerbose
  optionVerbose="$(Options::generateOption --help "verbose mode" \
    --variable-name "verbose" --alt "--verbose" --alt "-v")" || return 1
  sourceFunctionFile "${optionVerbose}"

  local optionSrcDirs
  optionSrcDirs="$(Options::generateOption --variable-type StringArray \
    --help "provide the directory where to find the functions source code." \
    --variable-name "srcDirs" --alt "--src-dirs" --alt "-s")" || return 1
  sourceFunctionFile "${optionSrcDirs}"

  local srcFile
  srcFile="$(Options::generateArg --variable-name "srcFile")" || return 1
  sourceFunctionFile "${srcFile}"

  local destFiles
  destFiles="$(Options::generateArg --variable-name "destFiles" --max 3)" || return 1
  sourceFunctionFile "${destFiles}"

  local status=0
  Options::generateCommand --help "super command" \
    ${optionVerbose} \
    ${optionSrcDirs} \
    ${srcFile} \
    ${destFiles} \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  testCommand "generateCommand.case4.sh" "Options::command"
}

function Options::generateCommand::case4::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case4.sh"
  run Options::command help
  checkCommandResult "generateCommand.case4.expected.help"
}

function Options::generateCommand::case4::parseNoArg { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case4.sh"
  local status=0
  local verbose
  local -a srcDirs=("initialDir")
  local srcFile="initialFile"
  local -a destFiles=("initialDestDir")
  Options::command parse >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "${verbose}" = "0" ]]
  [[ "${srcDirs[*]}" = "initialDir" ]]
  [[ "${srcFile}" = "initialFile" ]]
  [[ "${destFiles[*]}" = "initialDestDir" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Argument 'srcFile' should be provided at least 1 time(s)"
}

function Options::generateCommand::case4::parseInvalidOption { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case4.sh"
  local status=0
  local verbose
  local -a srcDirs=("initialDir")
  local srcFile="initialFile"
  local -a destFiles=("initialDestDir")
  Options::command parse --invalid-option >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "${verbose}" = "0" ]]
  [[ "${srcDirs[*]}" = "initialDir" ]]
  [[ "${srcFile}" = "initialFile" ]]
  [[ "${destFiles[*]}" = "initialDestDir" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Invalid option --invalid-option"
}

function Options::generateCommand::case4::parseAll { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case4.sh"
  local status=0
  local verbose
  local -a srcDirs=("initialDir")
  local srcFile="initialFile"
  local -a destFiles=("initialDestDir")
  Options::command parse initialFile2 --verbose destFile1 --src-dirs srcDir1 destFile2 -s srcDir2 destFile3 >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${verbose}" = "1" ]]
  [[ "${srcDirs[*]}" = "initialDir srcDir1 srcDir2" ]]
  [[ "${srcFile}" = "initialFile2" ]]
  [[ "${destFiles[*]}" = "initialDestDir destFile1 destFile2 destFile3" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Options::generateCommand::case4::destFile4 { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case4.sh"
  local status=0
  local verbose
  local -a srcDirs=("initialDir")
  local srcFile="initialFile"
  local -a destFiles=("initialDestDir")
  Options::command parse initialFile2 --verbose destFile1 --src-dirs srcDir1 destFile2 -s srcDir2 destFile3 destFile4 >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "${verbose}" = "1" ]]
  [[ "${srcDirs[*]}" = "initialDir srcDir1 srcDir2" ]]
  [[ "${srcFile}" = "initialFile2" ]]
  [[ "${destFiles[*]}" = "initialDestDir destFile1 destFile2 destFile3" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output --partial "ERROR   - Argument destFiles - Maximum number of argument occurrences reached(3)"
}

function Options::generateCommand::case5::invalidArgOrder { #@test
  local srcFile
  srcFile="$(Options::generateArg --variable-name "srcFile")" || return 1
  sourceFunctionFile "${srcFile}"

  local destFiles
  destFiles="$(Options::generateArg --variable-name "destFiles" --max 3)" || return 1
  sourceFunctionFile "${destFiles}"

  run Options::generateCommand --help "super command" "${destFiles}" "${srcFile}"
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateCommand - variable list argument srcFile after an other variable list argument destFiles, it would not be possible to discriminate them"
}

# group management
function Options::generateCommand::case6 { #@test
  function helpCallback() {
    echo "helpCallback"
  }
  local optionHelp="$(Options::generateOption --variable-type Boolean --help "help" \
    --variable-name "help" --alt "--help" --alt "-h" --callback helpCallback)" || return 1
  sourceFunctionFile "${optionHelp}"

  local optionGroup="$(Options::generateGroup \
    --title "Command global options" \
    --help "The Console component adds some predefined options to all commands:")"
  sourceFunctionFile "${optionGroup}"

  local optionVerbose
  optionVerbose="$(Options::generateOption --help "verbose mode" \
    --group "${optionGroup}" \
    --variable-name "verbose" \
    --alt "--verbose" --alt "-v")" || return 1
  sourceFunctionFile "${optionVerbose}"

  local optionSrcDirs
  optionSrcDirs="$(Options::generateOption --variable-type StringArray \
    --help "provide the directory where to find the functions source code." \
    --variable-name "srcDirs" --alt "--src-dirs" --alt "-s")" || return 1
  sourceFunctionFile "${optionSrcDirs}"

  local optionQuiet
  optionQuiet="$(Options::generateOption --help "quiet mode" \
    --group "${optionGroup}" \
    --variable-name "quiet" \
    --alt "--quiet" --alt "-q")" || return 1
  sourceFunctionFile "${optionQuiet}"

  local status=0
  Options::generateCommand --help "super command" \
    ${optionVerbose} \
    ${optionQuiet} \
    ${optionHelp} \
    ${optionSrcDirs} \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  testCommand "generateCommand.case6.sh" "Options::command"
}

function Options::generateCommand::case6::help { #@test
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case6.sh"
  run Options::command help
  checkCommandResult "generateCommand.case6.expected.help"
}

function Options::generateCommand::case6::parseHelp { #@test
  function helpCallback() {
    echo "helpCallback"
  }
  source "${BATS_TEST_DIRNAME}/testsData/generateCommand.case6.sh"
  run Options::command parse --help
  assert_output "helpCallback"
}
