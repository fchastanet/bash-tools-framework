#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Implement/validateInterfaceFunctions.sh
source "${srcDir}/Compiler/Implement/validateInterfaceFunctions.sh"

function Compiler::Implement::validateInterfaceFunctions::noArg { #@test
  run Compiler::Implement::validateInterfaceFunctions
  assert_failure 1
  assert_output --partial "ERROR   - missing file"
}

function Compiler::Implement::validateInterfaceFunctions::invalidFile { #@test
  run Compiler::Implement::validateInterfaceFunctions "invalidFile"
  assert_failure 1
  assert_output --partial "ERROR   - missing file invalidFile"
}

function Compiler::Implement::validateInterfaceFunctions::noFunctionsPassed { #@test
  run Compiler::Implement::validateInterfaceFunctions \
    "${BATS_TEST_DIRNAME}/testsData/validateInterfaceFunctions.sh" "validateInterfaceFunctions.sh"
  assert_success
  assert_output ""
}

function Compiler::Implement::validateInterfaceFunctions::functionNotImplemented { #@test
  run Compiler::Implement::validateInterfaceFunctions \
    "${BATS_TEST_DIRNAME}/testsData/validateInterfaceFunctions.sh" "validateInterfaceFunctions.sh" \
    "invalidFunction"
  assert_failure 2
  assert_output --partial "ERROR   - function invalidFunction from interface is not implemented in validateInterfaceFunctions.sh"
}

function Compiler::Implement::validateInterfaceFunctions::OneFunctionImplemented { #@test
  run Compiler::Implement::validateInterfaceFunctions \
    "${BATS_TEST_DIRNAME}/testsData/validateInterfaceFunctions.sh" "validateInterfaceFunctions.sh" \
    "help"
  assert_success
  assert_output ""
}

function Compiler::Implement::validateInterfaceFunctions::AllFunctionsImplemented { #@test
  run Compiler::Implement::validateInterfaceFunctions \
    "${BATS_TEST_DIRNAME}/testsData/validateInterfaceFunctions.sh" "validateInterfaceFunctions.sh" \
    "help" "options" "install" "configure"

  assert_success
  assert_output ""
}

function Compiler::Implement::validateInterfaceFunctions::AllFunctionsImplementedExceptOne { #@test
  run Compiler::Implement::validateInterfaceFunctions \
    "${BATS_TEST_DIRNAME}/testsData/validateInterfaceFunctions.sh" "validateInterfaceFunctions.sh" \
    "help" "options" "install" "configure" "invalidFunction"

  assert_failure 2
  assert_output --partial "ERROR   - function invalidFunction from interface is not implemented in validateInterfaceFunctions.sh"
}
