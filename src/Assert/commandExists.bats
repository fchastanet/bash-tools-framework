#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/commandExists.sh
source "${srcDir}/Assert/commandExists.sh"

teardown() {
  unstub_all
}

function Assert::commandExists { #@test

  run Assert::commandExists "bash"
  assert_success
  assert_output ""
}

function Assert::commandExistsFalse { #@test
  run Assert::commandExists "invalidCommand"
  assert_failure
  assert_output --partial "ERROR   - invalidCommand is not installed, please install it"
}
