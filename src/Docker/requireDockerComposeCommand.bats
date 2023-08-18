#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Docker/requireDockerComposeCommand.sh
source "${srcDir}/Docker/requireDockerComposeCommand.sh"

function Docker::requireDockerComposeCommand::failureDockerAndDockerCompose { #@test
  function Assert::commandExists() {
    return 1
  }

  run Docker::requireDockerComposeCommand

  assert_failure 1
  assert_output ""
}

function Docker::requireDockerComposeCommand::failureDockerCompose { #@test
  function Assert::commandExists() {
    if [[ "$1" = "docker" ]]; then
      return 0
    fi
    return 1
  }

  run Docker::requireDockerComposeCommand

  assert_failure 1
  assert_output ""
}

function Docker::requireDockerComposeCommand::successDockerCompose { #@test
  function Assert::commandExists() {
    return 0
  }

  run Docker::requireDockerComposeCommand

  assert_success
  assert_output ""
}
