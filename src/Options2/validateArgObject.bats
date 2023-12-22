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

function Options2::validateArgObject::noOption { #@test
  run Options2::validateArgObject
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateArgObject - exactly one parameter has to be provided"
  assert_failure 1
}

function Options2::validateArgObject::missingValue { #@test
  run Options2::validateArgObject invalidObject
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateArgObject - passed object is not an argument"
  assert_failure 2
}

function Options2::validateArgObject::tooMuchArgs { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg"
  run Options2::validateArgObject argFunction argFunction 
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateArgObject - exactly one parameter has to be provided"
  assert_failure 1
}

function Options2::validateArgObject::invalidObjectType { #@test
  Object::create \
    --function-name "notAnargFunction" \
    --type "NotAnOption"

  run Options2::validateArgObject notAnargFunction
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateArgObject - passed object is not an argument"
  assert_failure 2
}

function Options2::validateArgObject::variableNameMandatory { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableType "String"

  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - variableName is mandatory"
  assert_failure 1
  assert_lines_count 1
}

function Options2::validateArgObject::variableNameInvalid { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-name "valid" \
    --property-variableName "François"

  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - invalid variableName François"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateArgObject::nameMandatory { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableName "validVariableName"

  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - name is mandatory"
  assert_failure 1
  assert_lines_count 1
}


function Options2::validateArgObject::nameInvalid { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableName "validVariableName" \
    --property-name "François"

  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - invalid name François"
  assert_failure 2
  assert_lines_count 1
}


function Options2::validateArgObject::callbackInvalid { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableName "varName" \
    --property-variableType "String" \
    --array-alt "--help" \
    --property-name "valid" \
    --array-callback "François"

  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - only posix or bash framework function name are accepted - invalid 'François'"
  assert_lines_count 1
  assert_failure 2
}

function Options2::validateArgObject::callbackValid { #@test
  callback() {
    :
  }
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableName "varName" \
    --property-variableType "String" \
    --array-alt "--help" \
    --property-name "valid" \
    --array-callback "callback"
  run Options2::validateArgObject argFunction
  assert_output ""
  assert_success
}

function Options2::validateArgObject::String::authorizedValuesValueInvalidValue { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableType "String" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-authorizedValues " invalid | valid" \
    --array-alt "--help"
  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - authorizedValues invalid regexp ' invalid | valid'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateArgObject::StringArray::authorizedValuesValueInvalidValue { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-authorizedValues " invalid | valid" \
    --array-alt "--help"
  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - authorizedValues invalid regexp ' invalid | valid'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateArgObject::regexpInvalid { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-regexp " " \
    --array-alt "--help"
  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - regexp invalid regexp ' '"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateArgObject::String::helpValueNameInvalidOption { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableType "String" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-helpValueName "invalid help" \
    --array-alt "--help"
  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - helpValueName should be a single word 'invalid help'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateArgObject::StringArray::helpValueNameInvalidOption { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-helpValueName "invalid help" \
    --array-alt "--help"
  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - helpValueName should be a single word 'invalid help'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateArgObject::StringArray::minValueEmpty { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-min "" \
    --array-alt "--help"
  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - min value should be an integer greater than or equal to 0"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateArgObject::StringArray::minValueInvalid { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-min "François" \
    --array-alt "--help"
  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - min value should be an integer greater than or equal to 0"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateArgObject::StringArray::minValueLessThan0 { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-min "-1" \
    --array-alt "--help"
  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - min value should be an integer greater than or equal to 0"
  assert_failure 2
  assert_lines_count 1
}


function Options2::validateArgObject::StringArray::minValueGreaterThanMaxValue { #@test
  Object::create \
    --function-name "argFunction" \
    --type "Arg" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-name "valid" \
    --property-min "3" \
    --property-max "1" \
    --array-alt "--help"
  run Options2::validateArgObject argFunction
  assert_output --partial "ERROR   - Options2::validateArgObject - max value should be greater than min value"
  assert_failure 2
  assert_lines_count 1
}