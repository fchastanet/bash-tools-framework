#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/tty.sh
source "${srcDir}/Assert/tty.sh"

teardown() {
  unstub_all
}

function Assert::tty { #@test
  run Assert::tty
  assert_failure
  assert_output ""
}
