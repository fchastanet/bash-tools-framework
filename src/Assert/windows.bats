#!/usr/bin/env bash

ROOT_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
vendorDir="${ROOT_DIR}/vendor"
srcDir="${ROOT_DIR}/src"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

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
