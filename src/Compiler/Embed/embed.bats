#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Compiler/Embed/embed.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/Compiler/Embed/embed.sh"
# shellcheck source=src/Assert/validVariableName.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/Assert/validVariableName.sh"
# shellcheck source=src/Assert/bashFrameworkFunction.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/Assert/bashFrameworkFunction.sh"
# shellcheck source=src/Filters/commentLines.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/Filters/commentLines.sh"

teardown() {
  unstub_all
}

Compiler::Embed::embedFile() {
  echo "embedFile $*"
}

Compiler::Embed::embedDir() {
  echo "embedDir $*"
}

Compiler::Embed::embedFrameworkFunction() {
  echo "embedFrameworkFunction $*"
}

function Compiler::Embed::embed::file { #@test
  run Compiler::Embed::embed "${BATS_TEST_DIRNAME}/embed.sh" "asName"
  assert_success
  assert_output "embedFile ${BATS_TEST_DIRNAME}/embed.sh asName"
}

function Compiler::Embed::embed::dir { #@test
  run Compiler::Embed::embed "${BATS_TEST_DIRNAME}" "asName"
  assert_success
  assert_output "embedDir ${BATS_TEST_DIRNAME} asName"
}

function Compiler::Embed::embed::function { #@test
  run Compiler::Embed::embed "Functions::myFunction" "asName"
  assert_success
  assert_output "embedFrameworkFunction Functions::myFunction asName"
}

function Compiler::Embed::embed::errorSrc { #@test
  run Compiler::Embed::embed "myFunction" "asName" 2>&1
  assert_failure 2
  assert_output --partial "ERROR   - invalid embedded resource myFunction"
}

function Compiler::Embed::embed::errorAsName { #@test
  run Compiler::Embed::embed "myFunction" "asName@dd" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - invalid embedded resource name format asName@dd"
}
