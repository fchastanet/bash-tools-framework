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

function Options2::renderGroupHelp::noOption { #@test
  run Options2::renderGroupHelp
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::renderGroupHelp - exactly one parameter has to be provided"
  assert_failure 1
}


function Options2::renderGroupHelp::groupOptionValid { #@test
  local status=0
  declare -a group=(
    --type "Group"
    --property-title "Global options"
    --property-help "help"
  )
  Options2::validateGroupObject() {
    return 0
  }
  run Options2::renderGroupHelp group >"${BATS_TEST_TMPDIR}/result" 2>&1
  assert_success
  assert_line --index 0 "$(echo -e "${__HELP_TITLE_COLOR}Global options${__RESET_COLOR}")"
  assert_line --index 1 "help"
}

function Options2::renderGroupHelp::groupObjectInvalid { #@test
  local status=0
  declare -a group=()
  Options2::validateGroupObject() {
    return 1
  }
  run Options2::renderGroupHelp group 2>&1
  assert_output ""
  assert_failure 2
}
