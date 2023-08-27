#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Options/generateOptionString.sh
source "${srcDir}/Options/generateOptionString.sh"
# shellcheck source=src/Array/contains.sh
source "${srcDir}/Array/contains.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
}

function Options::generateOptionString::noOption { #@test
  run Options::generateOptionString
  assert_success
  assert_lines_count 4
  assert_line --index 0 "export min='0'"
  assert_line --index 1 "export max='1'"
  assert_line --index 2 "export defaultValue=''"
  assert_line --index 3 "export authorizedValues=''"
}

function Options::generateOptionString::defaultValueMissingValue { #@test
  run Options::generateOptionString --default-value
  assert_success
  assert_lines_count 4
  assert_line --index 0 "export min='0'"
  assert_line --index 1 "export max='1'"
  assert_line --index 2 "export defaultValue=''"
  assert_line --index 3 "export authorizedValues=''"
}

function Options::generateOptionString::authorizedValuesValueMissingValue { #@test
  run Options::generateOptionString --authorized-values
  assert_success
  assert_lines_count 4
  assert_line --index 0 "export min='0'"
  assert_line --index 1 "export max='1'"
  assert_line --index 2 "export defaultValue=''"
  assert_line --index 3 "export authorizedValues=''"
}

function Options::generateOptionString::authorizedValuesValueInvalidValue { #@test
  run Options::generateOptionString --authorized-values " invalid | valid"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOptionString - --authorized-values invalid regexp ' invalid | valid'"
}

function Options::generateOptionString::setBoth { #@test
  run Options::generateOptionString --authorized-values "valid|invalid" --default-value "valid"
  assert_success
  assert_lines_count 4
  assert_line --index 0 "export min='0'"
  assert_line --index 1 "export max='1'"
  assert_line --index 2 "export defaultValue='valid'"
  assert_line --index 3 "export authorizedValues='valid|invalid'"
}

function Options::generateOptionString::setMandatory { #@test
  run Options::generateOptionString --authorized-values "valid|invalid" --default-value "valid" --mandatory
  assert_success
  assert_lines_count 4
  assert_line --index 0 "export min='1'"
  assert_line --index 1 "export max='1'"
  assert_line --index 2 "export defaultValue='valid'"
  assert_line --index 3 "export authorizedValues='valid|invalid'"
}
