#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/requireRealpathCommand.sh
source "${srcDir}/Linux/requireRealpathCommand.sh"

function Linux::requireRealpathCommand::failure { #@test
  function Assert::commandExists() {
    return 1
  }

  run Linux::requireRealpathCommand

  assert_failure 1
  assert_output ""
}

function Linux::requireRealpathCommand::success { #@test
  function Assert::commandExists() {
    return 0
  }

  run Linux::requireRealpathCommand

  assert_success
  assert_output ""
}
