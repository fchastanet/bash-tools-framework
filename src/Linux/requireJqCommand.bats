#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/requireJqCommand.sh
source "${srcDir}/Linux/requireJqCommand.sh"

function Linux::requireJqCommand::failure { #@test
  function Assert::commandExists() {
    return 1
  }

  run Linux::requireJqCommand

  assert_failure 1
  assert_output ""
}

function Linux::requireJqCommand::success { #@test
  function Assert::commandExists() {
    return 0
  }

  run Linux::requireJqCommand

  assert_success
  assert_output ""
}
