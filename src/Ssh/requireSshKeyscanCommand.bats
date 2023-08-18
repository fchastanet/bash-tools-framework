#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Ssh/requireSshKeyscanCommand.sh
source "${srcDir}/Ssh/requireSshKeyscanCommand.sh"

function Ssh::requireSshKeyscanCommand::failure { #@test
  function Assert::commandExists() {
    return 1
  }

  run Ssh::requireSshKeyscanCommand

  assert_failure 1
  assert_output ""
}

function Ssh::requireSshKeyscanCommand::success { #@test
  function Assert::commandExists() {
    return 0
  }

  run Ssh::requireSshKeyscanCommand

  assert_success
  assert_output ""
}
