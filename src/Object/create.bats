#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Object/__all.sh
source "${srcDir}/Object/__all.sh"
# shellcheck source=src/Assert/posixFunctionName.sh
source "${srcDir}/Assert/posixFunctionName.sh"
# shellcheck source=src/Array/contains.sh
source "${srcDir}/Array/contains.sh"

function Object::create::simpleObject { #@test
  declare simpleObjectFunction
  Object::create simpleObjectFunction \
    --type "simpleObjectType" \
    --property-property "propertyValue"
  
  run ${simpleObjectFunction} type
  assert_output "simpleObjectType"

  run ${simpleObjectFunction} strict
  assert_output "1"

  run ${simpleObjectFunction} functionName
  [[ "${simpleObjectFunction}" =~ ^[0-9a-f]{32}$ ]]

  run ${simpleObjectFunction} getProperty property
  assert_output "propertyValue"

  run ${simpleObjectFunction} invalidCommand
  assert_output --partial "ERROR   - invalid command invalidCommand"
  assert_failure 1

  run ${simpleObjectFunction} getProperty propertyUnknown
  assert_output --partial "ERROR   - unknown property propertyUnknown"
  assert_failure 2
}

function Object::create::missingPositionalArg { #@test
  declare missingPositionalArg
  run Object::create \
    --type "simpleObjectType" \
    --propertyInvalid-property "propertyValue" 2>&1
  
  assert_output --partial "local: \`--type': invalid variable name for name reference"
  assert_failure 1
}

function Object::create::simpleObjectNonStrict { #@test
  declare simpleObjectType
  Object::create simpleObjectType \
    --strict 0 \
    --type "simpleObjectType" \
    --property-property "propertyValue"
  
  run ${simpleObjectType} strict
  assert_output "0"

  run ${simpleObjectType} getProperty propertyUnknown
  assert_output ""
  assert_success
}

function Object::create::invalidProperty { #@test
  declare simpleObjectType
  run Object::create simpleObjectType \
    --type "simpleObjectType" \
    --propertyInvalid-property "propertyValue" 2>&1
  
  assert_output --partial "ERROR   - invalid object property --propertyInvalid-property"
  assert_failure 1
}

function Object::create::duplicatedProperty { #@test
  declare duplicatedProperty
  run Object::create duplicatedProperty \
    --type "simpleObjectType" \
    --property-property "propertyValue1" \
    --property-property "propertyValue2" 2>&1
  
  assert_output --partial "ERROR   - property property is provided more than one time"
  assert_failure 1
}

function Object::create::invalidObjectType { #@test
  declare invalidObjectType 
  run Object::create invalidObjectType \
    --type "invalidéObjectType" \
    --property-property "propertyValue" 2>&1
  
  assert_output --partial "ERROR   - invalid object type invalidéObjectType"
  assert_failure 1
}

function Object::create::missingObjectType { #@test
  run Object::create missingObjectType \
    --property-property "propertyValue" 2>&1
  
  assert_output --partial "ERROR   - missing object type"
  assert_failure 1
}

function Object::create::unknownArray { #@test
  declare unknownArray
  Object::create unknownArray \
    --type "simpleObjectType" \
    --array-list "unknownArray" 2>&1
  
  run ${unknownArray} getArray "unknownArray"
  
  assert_output --partial "ERROR   - unknown array unknownArray"
  assert_failure 2
}

function Object::create::propertyArrayOrdered { #@test
  declare propertyArrayOrdered
  Object::create propertyArrayOrdered \
    --type "simpleObjectType" \
    --property-property "propertyValue" \
    --array-list "value1" \
    --array-list "value2"
  
  run ${propertyArrayOrdered} type
  assert_success
  assert_output "simpleObjectType"

  run ${propertyArrayOrdered} functionName
  [[ "${output}" =~ ^[0-9a-f]{32}$ ]]

  run ${propertyArrayOrdered} getProperty property
  assert_success
  assert_output "propertyValue"

  run ${propertyArrayOrdered} getArray list
  assert_success
  assert_lines_count 2
  assert_line --index 0 "value1"
  assert_line --index 1 "value2"
}

function Object::create::propertyArrayUnordered { #@test
  declare propertyArrayUnordered
  Object::create propertyArrayUnordered \
    --type "simpleObjectType" \
    --array-list "value1" \
    --array-list "value2" \
    --property-property "propertyValue" \
    --array-list "value3"
  
  run ${propertyArrayUnordered} type
  assert_success
  assert_output "simpleObjectType"

  run ${propertyArrayUnordered} functionName
  [[ "${output}" =~ ^[0-9a-f]{32}$ ]]

  run ${propertyArrayUnordered} getProperty property
  assert_success
  assert_output "propertyValue"

  run ${propertyArrayUnordered} getArray list
  assert_success
  assert_lines_count 3
  assert_line --index 0 "value1"
  assert_line --index 1 "value2"
  assert_line --index 2 "value3"

  run ${propertyArrayUnordered} getMembers
  assert_success
  assert_lines_count 2
  assert_line --index 0 "list"
  assert_line --index 1 "property"
}