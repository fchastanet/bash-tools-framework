#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/requirePathchkCommand.sh
source "${srcDir}/Linux/requirePathchkCommand.sh"

function Linux::requirePathchkCommand::failure { #@test
  function Assert::commandExists() {
    return 1
  }

  run Linux::requirePathchkCommand

  assert_failure 1
  assert_output ""
}

function Linux::requirePathchkCommand::success { #@test
  function Assert::commandExists() {
    return 0
  }

  run Linux::requirePathchkCommand

  assert_success
  assert_output ""
}
