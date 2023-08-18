#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Ssh/requireSshKeygenCommand.sh
source "${srcDir}/Ssh/requireSshKeygenCommand.sh"

function Ssh::requireSshKeygenCommand::failure { #@test
  function Assert::commandExists() {
    return 1
  }

  run Ssh::requireSshKeygenCommand

  assert_failure 1
  assert_output ""
}

function Ssh::requireSshKeygenCommand::success { #@test
  function Assert::commandExists() {
    return 0
  }

  run Ssh::requireSshKeygenCommand

  assert_success
  assert_output ""
}
