#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Options/generateOption.sh
source "${srcDir}/Options/generateOption.sh"
# shellcheck source=src/Options/generateFunctionName.sh
source "${srcDir}/Options/generateFunctionName.sh"
# shellcheck source=src/Options/generateOptionBoolean.sh
source "${srcDir}/Options/generateOptionBoolean.sh"
# shellcheck source=src/Options/assertAlt.sh
source "${srcDir}/Options/assertAlt.sh"
# shellcheck source=src/Options/bashTpl.sh
source "${srcDir}/Options/bashTpl.sh"
# shellcheck source=/src/Assert/validVariableName.sh
source "${srcDir}/Assert/validVariableName.sh"
# shellcheck source=/src/Array/contains.sh
source "${srcDir}/Array/contains.sh"
# shellcheck source=/src/Array/join.sh
source "${srcDir}/Array/join.sh"
# shellcheck source=/src/Framework/createTempFile.sh
source "${srcDir}/Framework/createTempFile.sh"
# shellcheck source=/src/Crypto/uuidV4.sh
source "${srcDir}/Crypto/uuidV4.sh"

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
  assert_output --partial "ERROR   - Options::generateOption - invalid variable name"
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
  assert_output --partial "ERROR   - Options::generateOption - invalid alt option value ''"
}

function Options::generateOption::invalidAltValue { #@test
  run Options::generateOption --variable-name "varName" --alt François
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - invalid alt option value 'François'"
}

function Options::generateOption::invalidTypeMissingValue { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --type
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - type '' invalid, should be one of Boolean String StringArray"
}

function Options::generateOption::invalidTypeValue { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --type "invalid"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - type 'invalid' invalid, should be one of Boolean String StringArray"
}

function Options::generateOption::typeOptionTwice { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --type "String" --type "StringArray"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - only one '--type' option can be provided"
}

function Options::generateOption::invalidCommandMissingValue { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --command
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - command parameter value '' should target a valid variable name"
}

function Options::generateOption::invalidCommandValue { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --command "François"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - command parameter value 'François' should target a valid variable name"
}

function Options::generateOption::commandOptionTwice { #@test
  run Options::generateOption --variable-name "varName" --alt "--var" --command "command" --command "command2"
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "ERROR   - Options::generateOption - only one '--command' option can be provided"
}

# TODO case with arguments function
