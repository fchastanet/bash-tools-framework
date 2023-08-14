#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Aws/requireAwsCommand.sh
source "${srcDir}/Aws/requireAwsCommand.sh"

function Aws::requireAwsCommand::failure { #@test
  function Assert::commandExists() {
    return 1
  }

  run Aws::requireAwsCommand

  assert_failure 1
  assert_output ""
}

function Aws::requireAwsCommand::success { #@test
  function Assert::commandExists() {
    return 0
  }

  run Aws::requireAwsCommand

  assert_success
  assert_output ""
}
