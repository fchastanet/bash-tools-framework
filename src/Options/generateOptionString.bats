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
  assert_lines_count 3
  assert_line --index 0 "export min='0'"
  assert_line --index 1 "export max='1'"
  assert_line --index 2 "export defaultValue=''"
}

function Options::generateOptionString::defaultValueMissingValue { #@test
  run Options::generateOptionString --default-value
  assert_success
  assert_lines_count 3
  assert_line --index 0 "export min='0'"
  assert_line --index 1 "export max='1'"
  assert_line --index 2 "export defaultValue=''"
}

function Options::generateOptionString::authorizedValuesValueMissingValue { #@test
  run Options::generateOptionString --authorized-values
  assert_success
  assert_lines_count 3
  assert_line --index 0 "export min='0'"
  assert_line --index 1 "export max='1'"
  assert_line --index 2 "export defaultValue=''"
}

function Options::generateOptionString::setBoth { #@test
  run Options::generateOptionString --mandatory --default-value "valid" --help-value-name "ignore"
  assert_success
  assert_lines_count 3
  assert_line --index 0 "export min='1'"
  assert_line --index 1 "export max='1'"
  assert_line --index 2 "export defaultValue='valid'"
}

function Options::generateOptionString::setMandatory { #@test
  run Options::generateOptionString --authorized-values "valid|invalid" --default-value "valid" --mandatory
  assert_success
  assert_lines_count 3
  assert_line --index 0 "export min='1'"
  assert_line --index 1 "export max='1'"
  assert_line --index 2 "export defaultValue='valid'"
}

function Options::generateOptionString::invalidOption { #@test
  run Options::generateOptionString --authorized-values "valid|invalid" --default-value "valid" --invalid
  assert_failure 1
  assert_lines_count 1
  assert_line --index 0 --partial "ERROR   - Options::generateOptionString - invalid option '--invalid'"
}
