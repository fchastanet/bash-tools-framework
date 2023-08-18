#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=/src/Profiles/lintDefinitions.sh
source "${srcDir}/Profiles/lintDefinitions.sh"
# shellcheck source=/src/Filters/removeAnsiCodes.sh
source "${srcDir}/Filters/removeAnsiCodes.sh"

teardown() {
  unstub_all
}

function Profiles::lintDefinitionsWithErrorsPlain { #@test
  run Profiles::lintDefinitions \
    "${BATS_TEST_DIRNAME}/testsData/lintDefinitions/KO" "plain"
  assert_failure 1
  # shellcheck disable=SC2154
  diff "${BATS_TEST_DIRNAME}/testsData/lintDefinitions/KO/expectedLintResult.plain.txt" <(echo "${output}" | Filters::removeAnsiCodes)
}

function Profiles::lintDefinitionsWithErrorsCheckstyle { #@test
  run Profiles::lintDefinitions \
    "${BATS_TEST_DIRNAME}/testsData/lintDefinitions/KO" "checkstyle"

  assert_failure 1
  diff "${BATS_TEST_DIRNAME}/testsData/lintDefinitions/KO/expectedLintResult.checkstyle.xml" <(echo "${output}")
}

function Profiles::lintDefinitionsOKPlain { #@test
  run Profiles::lintDefinitions \
    "${BATS_TEST_DIRNAME}/testsData/lintDefinitions/OK" "plain"
  assert_success
  assert_output --partial "SUCCESS - No lint error found !"
}

function Profiles::lintDefinitionsOKCheckstyle { #@test
  run Profiles::lintDefinitions \
    "${BATS_TEST_DIRNAME}/testsData/lintDefinitions/OK" "checkstyle"

  assert_success
  [[ "$(cat "${BATS_TEST_DIRNAME}/testsData/lintDefinitions/OK/expectedLintResult.checkstyle.xml")" = "${output}" ]]
}
