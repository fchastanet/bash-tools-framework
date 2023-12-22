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

function Object::getProperty::simpleObject { #@test
  declare -a simpleObject=(
    --type "simpleObjectType"
    --property-property "propertyValue"
  )
  run Object::getProperty simpleObject property 1
  assert_output "propertyValue"
  assert_success

  run Object::getProperty simpleObject property 0
  assert_output "propertyValue"
  assert_success
}

function Object::getProperty::unknownProperty { #@test
  declare -a simpleObject=(
    --type "simpleObjectType"
    --property-property "propertyValue"
  )
  run Object::getProperty simpleObject unknownProperty 1
  assert_output --partial "ERROR   - unknown property unknownProperty"
  assert_failure 1

  run Object::getProperty simpleObject unknownProperty 0
  assert_output ""
  assert_success
}
