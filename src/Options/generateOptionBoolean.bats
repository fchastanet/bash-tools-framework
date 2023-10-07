#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Options/generateOptionBoolean.sh
source "${srcDir}/Options/generateOptionBoolean.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
}

function Options::generateOptionBoolean::noOption { #@test
  run Options::generateOptionBoolean
  assert_success
  assert_lines_count 4
  assert_line --index 0 "export min='0'"
  assert_line --index 1 "export max='1'"
  assert_line --index 2 "export onValue='1'"
  assert_line --index 3 "export offValue='0'"
}

function Options::generateOptionBoolean::onValueMissingValue { #@test
  run Options::generateOptionBoolean --on-value
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOptionBoolean - --on-value cannot be empty"
}

function Options::generateOptionBoolean::offValueMissingValue { #@test
  run Options::generateOptionBoolean --off-value
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOptionBoolean - --off-value cannot be empty"
}

function Options::generateOptionBoolean::onOffSameValue { #@test
  run Options::generateOptionBoolean --on-value 1 --off-value 1
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOptionBoolean - --on-value and --off-value cannot be equal"
}

function Options::generateOptionBoolean::mandatoryIgnored { #@test
  run Options::generateOptionBoolean --on-value 12 --off-value 14 --mandatory
  assert_success
  assert_lines_count 5
  assert_line --index 0 --partial "SKIPPED - Options::generateOptionBoolean - --mandatory is incompatible with Boolean type, ignored"
  assert_line --index 1 "export min='0'"
  assert_line --index 2 "export max='1'"
  assert_line --index 3 "export onValue='12'"
  assert_line --index 4 "export offValue='14'"
}
