#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/requireSudoCommand.sh
source "${srcDir}/Linux/requireSudoCommand.sh"

function Linux::requireSudoCommand::failure { #@test
  function Assert::commandExists() {
    return 1
  }

  run Linux::requireSudoCommand

  assert_failure 1
  assert_output ""
}

function Linux::requireSudoCommand::success { #@test
  function Assert::commandExists() {
    return 0
  }

  run Linux::requireSudoCommand

  assert_success
  assert_output ""
}
