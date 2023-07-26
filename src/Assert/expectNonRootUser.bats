#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/expectNonRootUser.sh
source "${srcDir}/Assert/expectNonRootUser.sh"

teardown() {
  unstub_all
}

function Assert::expectNonRootUser::root { #@test
  stub id '-u : echo "0"'
  run Assert::expectNonRootUser
  assert_failure 1
  assert_output --partial "The script must not be run as root"
}

function Assert::expectNonRootUser::NotRoot { #@test
  stub id '-u : echo "1000"'
  run Assert::expectNonRootUser
  assert_success
  assert_output ""
}
