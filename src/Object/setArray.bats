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

function Object::setArray::simpleObject { #@test
  declare -a simpleObject=(
    --type "simpleObjectType"
    --array-list "elem1" --
    --property-property "propertyValue"
  )
  local status=0
  Object::setArray simpleObject --array-list "newElem1" "newElem2" || status=1
  [[ "${status}" = "0" ]]
  run echo "${simpleObject[@]}"
  assert_output "--type simpleObjectType --property-property propertyValue --array-list newElem1 newElem2 --"
}

function Object::setArray::multipleElements { #@test
  declare -a multipleElements=(
    --type "multipleElementsType"
    --array-list "elem1" "elem2" "elem3" --
    --property-property "propertyValue"
  )
  local status=0
  Object::setArray multipleElements --array-list "newElem1" "newElem2" || status=1
  [[ "${status}" = "0" ]]
  run echo "${multipleElements[@]}"
  assert_output "--type multipleElementsType --property-property propertyValue --array-list newElem1 newElem2 --"
}

function Object::setArray::missingArrayTerminator { #@test
  declare -a missingArrayTerminator=(
    --type "missingArrayTerminatorType"
    --array-list "elem1" "elem2" "elem3"
    --property-property "propertyValue"
  )
  local status=0
  Object::setArray missingArrayTerminator --array-list "newElem1" "newElem2" || status=1
  [[ "${status}" = "0" ]]
  run echo "${missingArrayTerminator[@]}"
  assert_output "--type missingArrayTerminatorType --array-list newElem1 newElem2 --"
}

function Object::setArray::customArrayTerminator { #@test
  declare -a customArrayTerminator=(
    --type "customArrayTerminatorType"
    --array-list "elem1" "elem2" "elem3" "@@@"
    --property-property "propertyValue"
  )
  local status=0
  OBJECT_TEMPLATE_ARRAY_TERMINATOR="@@@" Object::setArray customArrayTerminator --array-list "newElem1" "newElem2" || status=1
  [[ "${status}" = "0" ]]
  run echo "${customArrayTerminator[@]}"
  assert_output "--type customArrayTerminatorType --property-property "propertyValue" --array-list newElem1 newElem2 @@@"
}

function Object::setArray::newProperty { #@test
  declare -a newPropertyObject=(
    --type "simpleObjectType"
    --property-property "propertyValue"
  )
  local status=0
  Object::setArray newPropertyObject --array-list "newElem1" "newElem2" || status=1
  [[ "${status}" = "0" ]]
  run echo "${newPropertyObject[@]}"
  assert_output "--type simpleObjectType --property-property propertyValue --array-list newElem1 newElem2 --"
}
