#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/requireYqCommand.sh
source "${srcDir}/Linux/requireYqCommand.sh"

function Linux::requireYqCommand::failure { #@test
  function Assert::commandExists() {
    return 1
  }

  run Linux::requireYqCommand

  assert_failure 1
  assert_output ""
}

function Linux::requireYqCommand::success { #@test
  function Assert::commandExists() {
    return 0
  }

  run Linux::requireYqCommand

  assert_success
  assert_output ""
}
