#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Args/parseVerbose.sh
source "${srcDir}/Args/parseVerbose.sh"

function Args::parseVerbose::noArg { #@test
  export BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_WARNING}
  local status=0
  Args::parseVerbose "${__LEVEL_INFO}" || status=$?
  [[ "${status}" = "1" ]]
  [[ "${ARGS_VERBOSE}" = "0" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "${__LEVEL_WARNING}" ]]
}

function Args::parseVerbose::noVerboseArg { #@test
  export BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_WARNING}
  local status=0
  Args::parseVerbose "${__LEVEL_INFO}" --arg1 --arg2 fixedArg || status=$?
  [[ "${status}" = "1" ]]
  [[ "${ARGS_VERBOSE}" = "0" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "${__LEVEL_WARNING}" ]]
}

function Args::parseVerbose::shortVerboseArg { #@test
  export BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_WARNING}
  local status=0
  Args::parseVerbose "${__LEVEL_INFO}" --arg1 --arg2 fixedArg -v || status=$?
  [[ "${status}" = "0" ]]
  [[ "${ARGS_VERBOSE}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "${__LEVEL_INFO}" ]]
}

function Args::parseVerbose::longVerboseArg { #@test
  export BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_WARNING}
  local status=0
  Args::parseVerbose "${__LEVEL_INFO}" --arg1 --arg2 fixedArg --verbose || status=$?
  [[ "${status}" = "0" ]]
  [[ "${ARGS_VERBOSE}" = "1" ]]
  [[ "${BASH_FRAMEWORK_DISPLAY_LEVEL}" = "${__LEVEL_INFO}" ]]
}
