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

function Object::memberExists::simpleObject { #@test
  declare -a simpleObject=(
    --type "simpleObjectType"
    --property-property "propertyValue"
  )
  run Object::memberExists simpleObject --property-property
  assert_output ""
  assert_success
}

function Object::memberExists::unknownProperty { #@test
  declare -a simpleObject=(
    --type "simpleObjectType"
    --property-property "propertyValue"
  )
  run Object::memberExists simpleObject --property-unknownProperty
  assert_output ""
  assert_failure 1
}

function Object::memberExists::withArray { #@test
  declare -a simpleObject=(
    --type "simpleObjectType"
    --array-list "elem1" --
    --property-property "propertyValue"
  )
  run Object::memberExists simpleObject --property-property
  assert_output ""
  assert_success

}

function Object::memberExists::property2 { #@test
  declare -a simpleObject=(
    --type "simpleObjectType"
    --array-list "elem1" --
    --property-property "propertyValue"
    --property-property2 "propertyValue2"
  )
  run Object::memberExists simpleObject --property-property2
  assert_output ""
  assert_success
}
