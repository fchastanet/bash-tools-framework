#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/getCodename.sh
source "${srcDir}/Linux/getCodename.sh"

function Linux::getCodename::failure { #@test
  source() {
    exit 1
  }

  run Linux::getCodename

  assert_failure 1
  assert_output ""
}

function Linux::getCodename::success { #@test
  source() {
    if [[ "$1" != "/etc/os-release" ]]; then
      exit 1
    fi
    echo "focal"
  }

  run Linux::getCodename

  assert_success
  assert_output "focal"
}
