#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Options/_bats.sh
source "${srcDir}/Options/_bats.sh"
# shellcheck source=src/Options2/__all.sh
source "${srcDir}/Options2/__all.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
}

function Options2::renderArgHelp::noOption { #@test
  run Options2::renderArgHelp
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::renderArgHelp - exactly one parameter has to be provided"
  assert_failure 1
}

function Options2::renderArgHelp::invalidObject1 { #@test
  declare -a invalidObject1=()
  run Options2::renderArgHelp invalidObject1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateArgObject - passed object is not an argument"
  assert_failure 2
}

function Options2::renderArgHelp::invalidObject2 { #@test
  invalidObject2() { :; }
  run Options2::renderArgHelp invalidObject2
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateArgObject - passed object is not an argument"
  assert_failure 2
}

function Options2::renderArgHelp::notAnOption { #@test
   declare -a notAnOption=(
    --type "NotAnOption"
  )

  run Options2::renderArgHelp notAnOptionFunction
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateArgObject - passed object is not an argument"
  assert_failure 2
}

function Options::renderArgHelp::OptionValid { #@test
  local status=0
  declare -a arg=(
    --type "Arg"
    --property-variableName "var"
    --property-name "name"
    --property-help "help"
    --property-title "Global options"
  )
  Options2::validateArgObject() {
    return 0
  }
  run Options2::renderArgHelp arg 2>&1
  assert_success
  assert_line --index 0 "[${__HELP_OPTION_COLOR}name${__HELP_NORMAL} {list} (optional)]"
  assert_line --index 1 "Global options"
  assert_line --index 2 "help"
  assert_lines_count 3
}
