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

function Options2::renderOptionHelp::noOption { #@test
  run Options2::renderOptionHelp
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::renderOptionHelp - exactly one parameter has to be provided"
  assert_failure 1
}

function Options2::renderOptionHelp::invalidObject { #@test
  function invalidObject() {
    :
  }
  run Options2::renderOptionHelp invalidObject
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateOptionObject - passed object is not an option"
  assert_failure 2
}

function Options2::renderOptionHelp::notAnOption { #@test
  Object::create \
    --type "NotAnOption" \
    --function-name "notAnOptionFunction"

  run Options2::renderOptionHelp notAnOptionFunction
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateOptionObject - passed object is not an option"
  assert_failure 2
}

function Options::renderOptionHelp::OptionValid { #@test
  local status=0
    callback() {
    :
  }
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableName "var" \
    --property-variableType "Boolean" \
    --property-help "help" \
    --property-title "Global options" \
    --array-alt "--help"

  run Options2::renderOptionHelp optionFunction 2>&1
  assert_success
  assert_line --index 0 "$(echo -e "${__HELP_TITLE_COLOR}Global options${__RESET_COLOR}")"
  assert_line --index 1 "help"
}
