#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Docker/requireDockerCommand.sh
source "${srcDir}/Docker/requireDockerCommand.sh"

function Docker::requireDockerCommand::failure { #@test
  function Assert::commandExists() {
    return 1
  }

  run Docker::requireDockerCommand

  assert_failure 1
  assert_output ""
}

function Docker::requireDockerCommand::success { #@test
  function Assert::commandExists() {
    return 0
  }

  run Docker::requireDockerCommand

  assert_success
  assert_output ""
}
