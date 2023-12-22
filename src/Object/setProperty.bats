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

function Object::setProperty::simpleObject { #@test
  declare -a simpleObject=(
    --type "simpleObjectType"
    --property-property "propertyValue"
  )
  local status=0
  Object::setProperty simpleObject property "newPropertyValue" || status=1
  [[ "${status}" = "0" ]]
  run echo "${simpleObject[@]}"
  assert_output "--type simpleObjectType --property-property newPropertyValue"
}

function Object::setProperty::multipleProperties { #@test
  declare -a multipleProperties=(
    --type "multiplePropertiesType"
    --property-property "propertyValue"
    --property-property2 "propertyValue2"
  )
  local status=0
  Object::setProperty multipleProperties property "newPropertyValue" || status=1
  [[ "${status}" = "0" ]]
  run echo "${multipleProperties[@]}"
  assert_output "--type multiplePropertiesType --property-property newPropertyValue --property-property2 propertyValue2"
}

function Object::setProperty::newProperty { #@test
  declare -a newPropertyObject=(
    --type "simpleObjectType"
    --property-property "propertyValue"
  )
  local status=0
  Object::setProperty newPropertyObject newProperty "value" || status=1
  [[ "${status}" = "0" ]]
  run echo "${newPropertyObject[@]}"
  assert_output "--type simpleObjectType --property-property propertyValue --property-newProperty value"  
}
