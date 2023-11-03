#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Options/generateOptionCommonStringOrStringArray.sh
source "${srcDir}/Options/generateOptionCommonStringOrStringArray.sh"
# shellcheck source=src/Array/contains.sh
source "${srcDir}/Array/contains.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
}

function Options::generateOptionCommonStringOrStringArray::noOption { #@test
  run Options::generateOptionCommonStringOrStringArray "Options::generateOptionString"
  assert_success
  assert_lines_count 2
  assert_line --index 0 "export authorizedValues=''"
  assert_line --index 1 "export helpValueName='String'"
}

function Options::generateOptionCommonStringOrStringArray::authorizedValuesValueMissingValue { #@test
  run Options::generateOptionCommonStringOrStringArray "Options::generateOptionString" \
    --authorized-values
  assert_success
  assert_lines_count 2
  assert_line --index 0 "export authorizedValues=''"
  assert_line --index 1 "export helpValueName='String'"
}

function Options::generateOptionCommonStringOrStringArray::authorizedValuesValueInvalidValue { #@test
  run Options::generateOptionCommonStringOrStringArray "Options::generateOptionString"\
    --authorized-values " invalid | valid"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOptionString - --authorized-values invalid regexp ' invalid | valid'"
}

function Options::generateOptionCommonStringOrStringArray::helpValueNameInvalidOption { #@test
  run Options::generateOptionCommonStringOrStringArray "Options::generateOptionString" \
    --authorized-values "valid|invalid" --help-value-name "invalid help"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOptionString - --help-value-name should be a single word 'invalid help'"
}


function Options::generateOptionCommonStringOrStringArray::setAll { #@test
  run Options::generateOptionCommonStringOrStringArray "Options::generateOptionString" \
    --authorized-values "valid|invalid" --help-value-name "name"
  assert_success
  assert_lines_count 2
  assert_line --index 0 "export authorizedValues='valid|invalid'"
  assert_line --index 1 "export helpValueName='name'"
}

function Options::generateOptionCommonStringOrStringArray::setInvalidOption { #@test
  run Options::generateOptionCommonStringOrStringArray "Options::generateOptionString" \
    --authorized-values "valid|invalid" --other-param
  assert_success
  assert_line --index 0 "export authorizedValues='valid|invalid'"
  assert_line --index 1 "export helpValueName='String'"
}
