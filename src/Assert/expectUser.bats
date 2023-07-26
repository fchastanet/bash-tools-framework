#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/expectUser.sh
source "${srcDir}/Assert/expectUser.sh"

teardown() {
  unstub_all
}

function Assert::expectUser::valid { #@test
  stub id '-un : echo "user"'
  run Assert::expectUser "user"
  assert_success
  assert_output ""
}

function Assert::expectUser::notValid { #@test
  stub id '-un : echo "notUser"'
  run Assert::expectUser "user"
  assert_failure 1
  assert_output --partial "The script must be run as user"
}
