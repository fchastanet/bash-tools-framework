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

function Object::getArray::simpleObject { #@test
  declare -a simpleObject=(
    --type "simpleObjectType"
    --array-myList "elem1"
  )
  run Object::getArray simpleObject myList 1
  assert_output "elem1"
  assert_success

  run Object::getArray simpleObject myList 0
  assert_output "elem1"
  assert_success
}

function Object::getArray::multipleArrayValues { #@test
  declare -a multipleArrayValues=(
    --type "multipleArrayValuesType"
    --array-myList "elem1"
    --property-type "type"
    --array-myList "elem2"
  )
  run Object::getArray multipleArrayValues myList 1
  assert_lines_count 2
  assert_line --index 0 "elem1"
  assert_line --index 1 "elem2"
  assert_success

  run Object::getArray multipleArrayValues myList 0
  assert_lines_count 2
  assert_line --index 0 "elem1"
  assert_line --index 1 "elem2"
  assert_success
}

function Object::getArray::unknownProperty { #@test
  declare -a simpleObject=(
    --type "simpleObjectType"
    --property-property "propertyValue"
  )
  run Object::getArray simpleObject unknownArray 1
  assert_output --partial "ERROR   - unknown array unknownArray"
  assert_failure 1

  run Object::getArray simpleObject unknownArray 0
  assert_output ""
  assert_success
}
