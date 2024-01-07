#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Options/_bats.sh
source "${srcDir}/Options/_bats.sh"
# shellcheck source=src/Options2/__all.sh
source "${srcDir}/Options2/__all.sh"
# shellcheck source=src/Object/memberExists.sh
source "${srcDir}/Object/memberExists.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
}

function Options2::validateGroupObject::noOption { #@test
  run Options2::validateGroupObject
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateGroupObject - exactly one parameter has to be provided"
  assert_failure 1
}

function Options2::validateGroupObject::invalidObject { #@test
  function invalidObject() {
    :
  }
  run Options2::validateGroupObject invalidObject
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateGroupObject - passed object is not a group"
  assert_failure 2
}

function Options2::validateGroupObject::notAGroup { #@test
  local -a notAGroup=(
    --type "NotAGroup"
  )

  run Options2::validateGroupObject notAGroup
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateGroupObject - passed object is not a group"
  assert_failure 2
}

function Options2::validateGroupObject::missingTitle { #@test
  local -a simpleObject=(
    --type "Group"
  )

  run Options2::validateGroupObject simpleObject
  assert_output --partial "ERROR   - Options2::validateGroupObject - title is mandatory"
  assert_failure 3
  assert_lines_count 1
}

function Options::validateGroupObject::groupOptionValid { #@test
  local status=0
  local -a groupObject=(
    --type "Group"
    --property-title "Global options"
    --property-help "help"
  )
  run Options2::validateGroupObject groupObject >"${BATS_TEST_TMPDIR}/result" 2>&1
  assert_success
  assert_output ""
}
