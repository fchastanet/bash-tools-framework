#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Embed/include.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/Embed/include.sh"
# shellcheck source=src/Assert/validVariableName.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/Assert/validVariableName.sh"
# shellcheck source=src/Assert/bashFrameworkFunction.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/Assert/bashFrameworkFunction.sh"
# shellcheck source=src/Filters/bashCommentLines.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/Filters/bashCommentLines.sh"

teardown() {
  unstub_all
}

Embed::includeFile() {
  echo "includeFile $*"
}

Embed::includeDir() {
  echo "includeDir $*"
}

Embed::includeFrameworkFunction() {
  echo "includeFrameworkFunction $*"
}

function Embed::include::file { #@test
  run Embed::include "${BATS_TEST_DIRNAME}/include.sh" "asName"
  assert_success
  assert_output "includeFile ${BATS_TEST_DIRNAME}/include.sh asName"
}

function Embed::include::dir { #@test
  run Embed::include "${BATS_TEST_DIRNAME}" "asName"
  assert_success
  assert_output "includeDir ${BATS_TEST_DIRNAME} asName"
}

function Embed::include::function { #@test
  run Embed::include "Functions::myFunction" "asName"
  assert_success
  assert_output "includeFrameworkFunction Functions::myFunction asName"
}

function Embed::include::errorSrc { #@test
  run Embed::include "myFunction" "asName" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - invalid include myFunction"
}

function Embed::include::errorAsName { #@test
  run Embed::include "myFunction" "asName@dd" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - invalid include name format asName@dd"
}
