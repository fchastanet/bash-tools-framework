#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Options/_bats.sh
source "${srcDir}/Options/_bats.sh"

# shellcheck source=src/Options/__all.sh
source "${srcDir}/Options/__all.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
}

function Options::generateOption::noOption { #@test
  run Options::generateOption
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - --variable-name option is mandatory"
}

function Options::generateOption::missingValue { #@test
  run Options::generateOption --variable-name
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - Option --variable-name - a value needs to be specified"
}

function Options::generateOption::invalidValue { #@test
  run Options::generateOption --variable-name "François"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - invalid variable name"
}

function Options::generateOption::missingAltOption { #@test
  run Options::generateOption --variable-name "varName"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - you must provide at least one --alt option"
}

function Options::generateOption::missingAltValue { #@test
  run Options::generateOption --variable-name "varName" --alt
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - Option --alt - a value needs to be specified"
}

function Options::generateOption::invalidAltValue { #@test
  run Options::generateOption --variable-name "varName" --alt François
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - invalid alt option value 'François'"
}

function Options::generateOption::invalidTypeMissingValue { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --variable-type
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - Option --variable-type - a value needs to be specified"
}

function Options::generateOption::invalidTypeValue { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --variable-type "invalid"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - variable type 'invalid' invalid, should be one of Boolean String StringArray"
}

function Options::generateOption::typeOptionTwice { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --variable-type "String" --variable-type "StringArray"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - only one '--variable-type' option can be provided"
}

function Options::generateOption::groupOptionEmpty { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --group
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - Option --group - a value needs to be specified"
}

function Options::generateOption::groupOptionInvalid { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --group "invalid"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - only function type are accepted as group - invalid 'invalid'"
}

function Options::generateOption::groupOptionValid { #@test
  group() {
    :
  }
  local status=0
  Options::generateOption --variable-name "varName" --alt "--var" --group group >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseGroupOption.sh" "Options::option"
}

function Options::generateOption::callbackOptionEmpty { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --callback
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - Option --callback - a value needs to be specified"
}

function Options::generateOption::callbackOptionInvalid { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --callback "invalid"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - only function type are accepted as callback - invalid 'invalid'"
}

function Options::generateOption::callbackOptionValid { #@test
  callback() {
    :
  }
  local status=0
  Options::generateOption --variable-name "varName" --alt "--var" --callback callback >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateOption.caseCallbackOption.sh" "Options::option"
}
