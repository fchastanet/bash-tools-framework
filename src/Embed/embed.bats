#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Embed/embed.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/Embed/embed.sh"
# shellcheck source=src/Assert/validVariableName.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/Assert/validVariableName.sh"
# shellcheck source=src/Assert/bashFrameworkFunction.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/Assert/bashFrameworkFunction.sh"
# shellcheck source=src/Filters/commentLines.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/Filters/commentLines.sh"

teardown() {
  unstub_all
}

Embed::embedFile() {
  echo "embedFile $*"
}

Embed::embedDir() {
  echo "embedDir $*"
}

Embed::embedFrameworkFunction() {
  echo "embedFrameworkFunction $*"
}

function Embed::embed::file { #@test
  run Embed::embed "${BATS_TEST_DIRNAME}/embed.sh" "asName"
  assert_success
  assert_output "embedFile ${BATS_TEST_DIRNAME}/embed.sh asName"
}

function Embed::embed::dir { #@test
  run Embed::embed "${BATS_TEST_DIRNAME}" "asName"
  assert_success
  assert_output "embedDir ${BATS_TEST_DIRNAME} asName"
}

function Embed::embed::function { #@test
  run Embed::embed "Functions::myFunction" "asName"
  assert_success
  assert_output "embedFrameworkFunction Functions::myFunction asName"
}

function Embed::embed::errorSrc { #@test
  run Embed::embed "myFunction" "asName" 2>&1
  assert_failure 2
  assert_output --partial "ERROR   - invalid embedded resource myFunction"
}

function Embed::embed::errorAsName { #@test
  run Embed::embed "myFunction" "asName@dd" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - invalid embedded resource name format asName@dd"
}
