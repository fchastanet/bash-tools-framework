#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/Wsl/requireWsl.sh
source "${srcDir}/Linux/Wsl/requireWsl.sh"

function Linux::Wsl::requireWsl::failure { #@test
  Assert::wsl() {
    return 1
  }
  run Linux::Wsl::requireWsl
  assert_failure 1
  assert_output ""
}

function Linux::Wsl::requireWsl::success { #@test
  Assert::wsl() {
    return 0
  }
  File::garbageCollect() {
    return 0
  }
  run Linux::Wsl::requireWsl
  assert_success
  assert_output ""
}
