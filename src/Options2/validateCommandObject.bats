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

function Options2::validateCommandObject::noOption { #@test
  run Options2::validateCommandObject
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateCommandObject - exactly one parameter has to be provided"
  assert_failure 1
}

function Options2::validateCommandObject::missingValue { #@test
  run Options2::validateCommandObject invalidObject
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateCommandObject - passed object is not a command"
  assert_failure 2
}

function Options2::validateCommandObject::tooMuchArgs { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command"
  run Options2::validateCommandObject argFunction argFunction 
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateCommandObject - exactly one parameter has to be provided"
  assert_failure 1
}

function Options2::validateCommandObject::invalidObjectType { #@test
  Object::create \
    --function-name "notAnargFunction" \
    --type "NotACommand"

  run Options2::validateCommandObject notAnargFunction
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateCommandObject - passed object is not a command"
  assert_failure 2
}

function Options2::validateCommandObject::nameInvalid { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-name "François"

  run Options2::validateCommandObject argFunction
  assert_output --partial "ERROR   - Options2::validateCommandObject - invalid command name François"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateCommandObject::callbackInvalid { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-variableName "varName" \
    --property-variableType "String" \
    --array-alt "--help" \
    --property-name "valid" \
    --array-callback "François"

  run Options2::validateCommandObject argFunction
  assert_output --partial "ERROR   - Options2::validateCommandObject - only posix or bash framework function name are accepted - invalid 'François'"
  assert_lines_count 1
  assert_failure 2
}

function Options2::validateCommandObject::callbackValid { #@test
  callback() {
    :
  }
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-variableName "varName" \
    --property-variableType "String" \
    --array-alt "--help" \
    --property-name "valid" \
    --array-callback "callback"
  run Options2::validateCommandObject argFunction
  assert_output ""
  assert_success
}

function Options2::validateCommandObject::String::authorizedValuesValueInvalidValue { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-variableType "String" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-authorizedValues " invalid | valid" \
    --array-alt "--help"
  run Options2::validateCommandObject argFunction
  assert_output --partial "ERROR   - Options2::validateCommandObject - authorizedValues invalid regexp ' invalid | valid'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateCommandObject::StringArray::authorizedValuesValueInvalidValue { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-authorizedValues " invalid | valid" \
    --array-alt "--help"
  run Options2::validateCommandObject argFunction
  assert_output --partial "ERROR   - Options2::validateCommandObject - authorizedValues invalid regexp ' invalid | valid'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateCommandObject::regexpInvalid { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-regexp " " \
    --array-alt "--help"
  run Options2::validateCommandObject argFunction
  assert_output --partial "ERROR   - Options2::validateCommandObject - regexp invalid regexp ' '"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateCommandObject::String::helpValueNameInvalidOption { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-variableType "String" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-helpValueName "invalid help" \
    --array-alt "--help"
  run Options2::validateCommandObject argFunction
  assert_output --partial "ERROR   - Options2::validateCommandObject - helpValueName should be a single word 'invalid help'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateCommandObject::StringArray::helpValueNameInvalidOption { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-helpValueName "invalid help" \
    --array-alt "--help"
  run Options2::validateCommandObject argFunction
  assert_output --partial "ERROR   - Options2::validateCommandObject - helpValueName should be a single word 'invalid help'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateCommandObject::StringArray::minValueEmpty { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-min "" \
    --array-alt "--help"
  run Options2::validateCommandObject argFunction
  assert_output --partial "ERROR   - Options2::validateCommandObject - min value should be an integer greater than or equal to 0"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateCommandObject::StringArray::minValueInvalid { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-min "François" \
    --array-alt "--help"
  run Options2::validateCommandObject argFunction
  assert_output --partial "ERROR   - Options2::validateCommandObject - min value should be an integer greater than or equal to 0"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateCommandObject::StringArray::minValueLessThan0 { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-min "-1" \
    --array-alt "--help"
  run Options2::validateCommandObject argFunction
  assert_output --partial "ERROR   - Options2::validateCommandObject - min value should be an integer greater than or equal to 0"
  assert_failure 2
  assert_lines_count 1
}


function Options2::validateCommandObject::StringArray::minValueGreaterThanMaxValue { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Command" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-min "3" \
    --property-max "1" \
    --array-alt "--help"
  run Options2::validateCommandObject argFunction
  assert_output --partial "ERROR   - Options2::validateCommandObject - max value should be greater than min value"
  assert_failure 2
  assert_lines_count 1
}