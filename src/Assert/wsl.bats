#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/wsl.sh
source "${srcDir}/Assert/wsl.sh"

teardown() {
  unstub_all
}

function Assert::wsl::isGitBash { #@test
  stub uname "-o : echo 'Msys'"

  run Assert::wsl
  assert_failure 1
  assert_output ""
}

function Assert::wsl::isWsl { #@test
  stub uname "-o : echo 'GNU/Linux'"

  run Assert::wsl
  assert_success
  assert_output ""
}
