#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Options/_bats.sh
source "${srcDir}/Options/_bats.sh"
# shellcheck source=src/Object/__all.sh
source "${srcDir}/Object/__all.sh"
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
  declare -a object=(
    --type "Command"
  )
  run Options2::validateCommandObject object object 
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateCommandObject - exactly one parameter has to be provided"
  assert_failure 1
}

function Options2::validateCommandObject::invalidObjectType { #@test
  declare -a object=(
    --type "NotACommand"
  )

  run Options2::validateCommandObject object
  assert_lines_count 1
  assert_output --partial "ERROR   - Options2::validateCommandObject - passed object is not a command"
  assert_failure 2
}

function Options2::validateCommandObject::nameInvalid { #@test
  declare -a object=(
    --type "Command" \
    --property-name "François"
  )

  run Options2::validateCommandObject object
  assert_output --partial "ERROR   - Options2::validateCommandObject - invalid command name François"
  assert_failure 2
  assert_lines_count 1
}

function Options2::validateCommandObject::callbackInvalid { #@test
  declare -a object=(
    --type "Command"
    --property-variableName "varName"
    --property-variableType "String"
    --array-alt "--help"
    --property-name "valid"
    --array-callback "François"
  )

  run Options2::validateCommandObject object
  assert_output --partial "ERROR   - Options2::validateCommandObject - only function can be passed as callback - invalid 'François'"
  assert_lines_count 1
  assert_failure 2
}

function Options2::validateCommandObject::unknownOptionCallbackInvalid { #@test
  declare -a object=(
    --type "Command"
    --property-variableName "varName"
    --property-variableType "String"
    --array-alt "--help"
    --property-name "valid"
    --array-unknownOptionCallback "François"
  )

  run Options2::validateCommandObject object
  assert_output --partial "ERROR   - Options2::validateCommandObject - only function can be passed as callback - invalid 'François'"
  assert_lines_count 1
  assert_failure 2
}

function Options2::validateCommandObject::unknownArgumentCallbackInvalid { #@test
  declare -a object=(
    --type "Command"
    --property-variableName "varName"
    --property-variableType "String"
    --array-alt "--help"
    --property-name "valid"
    --array-unknownArgumentCallback "François"
  )

  run Options2::validateCommandObject object
  assert_output --partial "ERROR   - Options2::validateCommandObject - only function can be passed as callback - invalid 'François'"
  assert_lines_count 1
  assert_failure 2
}

function Options2::validateCommandObject::everyOptionCallbackInvalid { #@test
  declare -a object=(
    --type "Command"
    --property-variableName "varName"
    --property-variableType "String"
    --array-alt "--help"
    --property-name "valid"
    --array-everyOptionCallback "François"
  )

  run Options2::validateCommandObject object
  assert_output --partial "ERROR   - Options2::validateCommandObject - only function can be passed as callback - invalid 'François'"
  assert_lines_count 1
  assert_failure 2
}

function Options2::validateCommandObject::everyArgumentCallbackInvalid { #@test
  declare -a object=(
    --type "Command"
    --property-variableName "varName"
    --property-variableType "String"
    --array-alt "--help"
    --property-name "valid"
    --array-everyArgumentCallback "François"
  )

  run Options2::validateCommandObject object
  assert_output --partial "ERROR   - Options2::validateCommandObject - only function can be passed as callback - invalid 'François'"
  assert_lines_count 1
  assert_failure 2
}

