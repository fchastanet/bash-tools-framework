#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/windows.sh
source "${srcDir}/Assert/windows.sh"

teardown() {
  unstub_all
}

function Assert::windows { #@test
  stub uname "-o : echo 'Msys'"

  run Assert::windows
  assert_success
  assert_output ""
}
