#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Git/requireGitCommand.sh
source "${srcDir}/Git/requireGitCommand.sh"

function Git::requireGitCommand::failure { #@test
  function Assert::commandExists() {
    return 1
  }

  run Git::requireGitCommand

  assert_failure 1
  assert_output ""
}

function Git::requireGitCommand::success { #@test
  function Assert::commandExists() {
    return 0
  }

  run Git::requireGitCommand

  assert_success
  assert_output ""
}
