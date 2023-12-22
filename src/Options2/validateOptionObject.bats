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

function Options2::validateOptionObject::noOption { #@test
  run Options2::validateOptionObject
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateOptionObject - exactly one parameter has to be provided"
  assert_failure 1
}

function Options2::validateOptionObject::missingValue { #@test
  run Options2::validateOptionObject invalidObject
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateOptionObject - passed object is not an option"
  assert_failure 2
}

function Options2::validateOptionObject::tooMuchArgs { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option"
  run Options2::validateOptionObject optionFunction optionFunction 
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateOptionObject - exactly one parameter has to be provided"
  assert_failure 1
}

function Options2::validateOptionObject::invalidObjectType { #@test
  Object::create \
    --function-name "notAnOptionFunction" \
    --type "NotAnOption"

  run Options2::validateOptionObject notAnOptionFunction
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateOptionObject - passed object is not an option"
  assert_failure 2
}

function Options2::validateOptionObject::variableTypeMandatory { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableName "varName"

  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - variableType is mandatory"
  assert_lines_count 1
  assert_failure 1
}

function Options2::validateOptionObject::variableTypeInvalid { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "invalid" \
    --property-variableName "varName"

  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - invalid variableType invalid"
  assert_lines_count 1
  assert_failure 2
}

function Options2::validateOptionObject::variableNameMandatory { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "String"

  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - variableName is mandatory"
  assert_failure 1
  assert_lines_count 1
}

function Options2::validateOptionObject::variableNameInvalid { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableName "François"

  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - invalid variableName François"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateOptionObject::missingAltOption { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableName "varName" \
    --property-variableType "String"
  
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - you must provide at least one alt option"
  assert_lines_count 1
  assert_failure 1
}

function Options2::validateOptionObject::invalidAltValue { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableName "varName" \
    --property-variableType "String" \
    --array-alt "François"
  
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - invalid alt option value 'François'"
  assert_lines_count 1
  assert_failure 2
}

function Options2::validateOptionObject::groupOptionInvalid { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableName "varName" \
    --property-variableType "String" \
    --property-group "invalidGroup" \
    --array-alt "--help"
  
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - Group invalidGroup - is not a valid group object"
  assert_lines_count 1
  assert_failure 2
}

function Options2::validateOptionObject::groupOptionValid { #@test
  Object::create \
    --type "Group" \
    --property-title "Global options" \
    --property-help "help" \
    --function-name "groupObjectFunction"

  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableName "varName" \
    --property-variableType "String" \
    --property-group "groupObjectFunction" \
    --array-alt "--help"

  local status=0
  run Options2::validateOptionObject optionFunction
  assert_output ""
  assert_success
}

function Options2::validateOptionObject::callbackOptionInvalid { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableName "varName" \
    --property-variableType "String" \
    --array-alt "--help" \
    --array-callback "François"

  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - only posix or bash framework function name are accepted - invalid 'François'"
  assert_lines_count 1
  assert_failure 2
}

function Options2::validateOptionObject::callbackOptionValid { #@test
  callback() {
    :
  }
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableName "varName" \
    --property-variableType "String" \
    --array-alt "--help" \
    --array-callback "callback"
  run Options2::validateOptionObject optionFunction
  assert_output ""
  assert_success
}

function Options2::validateOptionObject::Boolean::onValueMissingValue { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "Boolean" \
    --property-variableName "varName" \
    --property-onValue "" \
    --array-alt "--help"
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - onValue cannot be empty"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateOptionObject::Boolean::offValueMissingValue { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "Boolean" \
    --property-variableName "varName" \
    --property-offValue "" \
    --array-alt "--help"
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - offValue cannot be empty"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateOptionObject::Boolean::onOffSameValue { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "Boolean" \
    --property-variableName "varName" \
    --property-offValue "1" \
    --property-onValue "1" \
    --array-alt "--help"
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - onValue and offValue cannot be equal"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateOptionObject::String::authorizedValuesValueInvalidValue { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "String" \
    --property-variableName "varName" \
    --property-authorizedValues " invalid | valid" \
    --array-alt "--help"
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - authorizedValues invalid regexp ' invalid | valid'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateOptionObject::StringArray::authorizedValuesValueInvalidValue { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-authorizedValues " invalid | valid" \
    --array-alt "--help"
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - authorizedValues invalid regexp ' invalid | valid'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateOptionObject::String::helpValueNameInvalidOption { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "String" \
    --property-variableName "varName" \
    --property-helpValueName "invalid help" \
    --array-alt "--help"
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - helpValueName should be a single word 'invalid help'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateOptionObject::StringArray::helpValueNameInvalidOption { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-helpValueName "invalid help" \
    --array-alt "--help"
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - helpValueName should be a single word 'invalid help'"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateOptionObject::StringArray::minValueEmpty { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-min "" \
    --array-alt "--help"
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - min value should be an integer greater than or equal to 0"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateOptionObject::StringArray::minValueInvalid { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-min "François" \
    --array-alt "--help"
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - min value should be an integer greater than or equal to 0"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateOptionObject::StringArray::minValueLessThan0 { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-min "-1" \
    --array-alt "--help"
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - min value should be an integer greater than or equal to 0"
  assert_failure 2
  assert_lines_count 1
}


function Options2::validateOptionObject::StringArray::minValueGreaterThanMaxValue { #@test
  Object::create \
    --function-name "optionFunction" \
    --type "Option" \
    --property-variableType "StringArray" \
    --property-variableName "varName" \
    --property-min "3" \
    --property-max "1" \
    --array-alt "--help"
  run Options2::validateOptionObject optionFunction
  assert_output --partial "ERROR   - Options2::validateOptionObject - max value should be greater than min value"
  assert_failure 2
  assert_lines_count 1
}