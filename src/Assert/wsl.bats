#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/wsl.sh
source "${srcDir}/Assert/wsl.sh"

teardown() {
  unstub_all
}

function Assert::wsl { #@test
  stub grep '-qEi "(Microsoft|WSL)" /proc/version : exit 0'

  run Assert::wsl
  assert_success
  assert_output ""
}
