#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Object/create.sh
source "${srcDir}/Object/create.sh"
# shellcheck source=src/Assert/posixFunctionName.sh
source "${srcDir}/Assert/posixFunctionName.sh"
# shellcheck source=src/Array/contains.sh
source "${srcDir}/Array/contains.sh"

function Object::create::simpleObject { #@test
  Object::create \
    --type "simpleObjectType" \
    --function-name "simpleObjectFunction" \
    --property-property "propertyValue"
  
  run simpleObjectFunction type
  assert_output "simpleObjectType"

  run simpleObjectFunction strict
  assert_output "1"

  run simpleObjectFunction functionName
  assert_output "simpleObjectFunction"

  run simpleObjectFunction get property
  assert_output "propertyValue"

  run simpleObjectFunction invalidCommand
  assert_output --partial "ERROR   - invalid command invalidCommand"
  assert_failure 1

  run simpleObjectFunction get propertyUnknown
  assert_output --partial "ERROR   - unknown property propertyUnknown"
  assert_failure 2
}

function Object::create::simpleObjectNonStrict { #@test
  Object::create \
    --strict 0 \
    --type "simpleObjectType" \
    --function-name "simpleObjectFunction" \
    --property-property "propertyValue"
  
  run simpleObjectFunction strict
  assert_output "0"

  run simpleObjectFunction get propertyUnknown
  assert_output ""
  assert_success
}

function Object::create::invalidProperty { #@test
  run Object::create \
    --type "simpleObjectType" \
    --function-name "simpleObjectFunction" \
    --propertyInvalid-property "propertyValue" 2>&1
  
  assert_output --partial "ERROR   - invalid object property --propertyInvalid-property"
  assert_failure 1
}

function Object::create::duplicatedProperty { #@test
  run Object::create \
    --type "simpleObjectType" \
    --function-name "simpleObjectFunction" \
    --property-property "propertyValue1" \
    --property-property "propertyValue2" 2>&1
  
  assert_output --partial "ERROR   - property property is provided more than one time"
  assert_failure 6
}

function Object::create::invalidFunctionName { #@test
  run Object::create \
    --type "simpleObjectType" \
    --function-name "invalidéFunctionName" \
    --property-property "propertyValue" 2>&1
  
  assert_output --partial "ERROR   - invalid object function name invalidéFunctionName"
  assert_failure 4
}

function Object::create::missingFunctionName { #@test
  run Object::create \
    --type "simpleObjectType" \
    --property-property "propertyValue" 2>&1
  
  assert_output --partial "ERROR   - missing object function name"
  assert_failure 3
}


function Object::create::invalidObjectType { #@test
  run Object::create \
    --type "invalidéObjectType" \
    --function-name "simpleFunctionName" \
    --property-property "propertyValue" 2>&1
  
  assert_output --partial "ERROR   - invalid object type invalidéObjectType"
  assert_failure 5
}

function Object::create::missingObjectType { #@test
  run Object::create \
    --function-name "simpleFunctionName" \
    --property-property "propertyValue" 2>&1
  
  assert_output --partial "ERROR   - missing object type"
  assert_failure 2
}

function Object::create::propertyArrayOrdered { #@test
  Object::create \
    --type "simpleObjectType" \
    --function-name "simpleObjectFunction" \
    --property-property "propertyValue" \
    --array-list "value1" \
    --array-list "value2"
  
  run simpleObjectFunction type
  assert_success
  assert_output "simpleObjectType"

  run simpleObjectFunction functionName
  assert_success
  assert_output "simpleObjectFunction"

  run simpleObjectFunction get property
  assert_success
  assert_output "propertyValue"

  run simpleObjectFunction get list
  assert_success
  assert_lines_count 2
  assert_line --index 0 "value1"
  assert_line --index 1 "value2"
}

function Object::create::propertyArrayUnordered { #@test
  Object::create \
    --type "simpleObjectType" \
    --array-list "value1" \
    --function-name "simpleObjectFunction" \
    --array-list "value2" \
    --property-property "propertyValue" \
    --array-list "value3"
  
  run simpleObjectFunction type
  assert_success
  assert_output "simpleObjectType"

  run simpleObjectFunction functionName
  assert_success
  assert_output "simpleObjectFunction"

  run simpleObjectFunction get property
  assert_success
  assert_output "propertyValue"

  run simpleObjectFunction get list
  assert_success
  assert_lines_count 3
  assert_line --index 0 "value1"
  assert_line --index 1 "value2"
  assert_line --index 2 "value3"

  run simpleObjectFunction getMembers
  assert_success
  assert_lines_count 2
  assert_line --index 0 "list"
  assert_line --index 1 "property"
}