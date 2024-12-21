#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Ssh/requireSshCommand.sh
source "${srcDir}/Ssh/requireSshCommand.sh"

function Ssh::requireSshCommand::failure { #@test
  function Assert::commandExists() {
    return 1
  }

  run Ssh::requireSshCommand

  assert_failure 1
  assert_output ""
}

function Ssh::requireSshCommand::success { #@test
  function Assert::commandExists() {
    return 0
  }

  run Ssh::requireSshCommand

  assert_success
  assert_output ""
}
