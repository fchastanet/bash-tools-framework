#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Options/generateOptionStringArray.sh
source "${srcDir}/Options/generateOptionStringArray.sh"
# shellcheck source=src/Array/contains.sh
source "${srcDir}/Array/contains.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
}

function Options::generateOptionStringArray::noOption { #@test
  run Options::generateOptionStringArray
  assert_success
  assert_lines_count 4
  assert_line --index 0 "export min='0'"
  assert_line --index 1 "export max='-1'"
  assert_line --index 2 "export authorizedValues=''"
  assert_line --index 3 "export helpValueName='String'"
}

function Options::generateOptionStringArray::mandatory { #@test
  run Options::generateOptionStringArray --mandatory
  assert_success
  assert_lines_count 4
  assert_line --index 0 "export min='1'"
  assert_line --index 1 "export max='-1'"
  assert_line --index 2 "export authorizedValues=''"
  assert_line --index 3 "export helpValueName='String'"
}

function Options::generateOptionStringArray::authorizedValuesValueMissingValue { #@test
  run Options::generateOptionStringArray --authorized-values
  assert_success
  assert_lines_count 4
  assert_line --index 0 "export min='0'"
  assert_line --index 1 "export max='-1'"
  assert_line --index 2 "export authorizedValues=''"
  assert_line --index 3 "export helpValueName='String'"
}

function Options::generateOptionStringArray::authorizedValuesValueInvalidValue { #@test
  run Options::generateOptionStringArray --authorized-values " invalid | valid"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOptionString - --authorized-values invalid regexp ' invalid | valid'"
}

function Options::generateOptionStringArray::minValueMissing { #@test
  run Options::generateOptionStringArray --min
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "Options::generateOptionStringArray - --min value should be an integer greater than or equal to 0"
}

function Options::generateOptionStringArray::minValueEmpty { #@test
  run Options::generateOptionStringArray --min ""
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "Options::generateOptionStringArray - --min value should be an integer greater than or equal to 0"
}

function Options::generateOptionStringArray::minValueInvalid { #@test
  run Options::generateOptionStringArray --min "François"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "Options::generateOptionStringArray - --min value should be an integer greater than or equal to 0"
}

function Options::generateOptionStringArray::minValueLessThan0 { #@test
  run Options::generateOptionStringArray --min "-1"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "Options::generateOptionStringArray - --min value should be an integer greater than or equal to 0"
}

function Options::generateOptionStringArray::minValueGreaterThanMaxValue { #@test
  run Options::generateOptionStringArray --min "3" --max "1"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOptionStringArray - --max value should be greater than --min value"
}

function Options::generateOptionStringArray::setAll { #@test
  run Options::generateOptionStringArray --authorized-values "valid|invalid" --min "1" --max "2"
  assert_success
  assert_lines_count 4
  assert_line --index 0 "export min='1'"
  assert_line --index 1 "export max='2'"
  assert_line --index 2 "export authorizedValues='valid|invalid'"
  assert_line --index 3 "export helpValueName='String'"
}

function Options::generateOptionStringArray::setInvalidOption { #@test
  run Options::generateOptionStringArray --authorized-values "valid|invalid" --min "1" --max "2" --other-param
  assert_failure 1
  assert_output --partial "ERROR   - Options::generateOption - invalid option '--other-param'"
}
