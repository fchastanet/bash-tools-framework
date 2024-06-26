#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/getDistributorId.sh
source "${srcDir}/Linux/getDistributorId.sh"

function Linux::getDistributorId::failure { #@test
  source() {
    exit 1
  }

  run Linux::getDistributorId

  assert_failure 1
  assert_output ""
}

function Linux::getDistributorId::success { #@test
  source() {
    if [[ "$1" != "/etc/os-release" ]]; then
      exit 1
    fi
    echo "Ubuntu"
  }

  run Linux::getDistributorId

  assert_success
  assert_output "Ubuntu"
}
