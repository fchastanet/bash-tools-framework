#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/requireUbuntu.sh
source "${srcDir}/Linux/requireUbuntu.sh"
# shellcheck source=src/Linux/getDistributorId.sh
source "${srcDir}/Linux/getDistributorId.sh"
# shellcheck source=src/Array/contains.sh
source "${srcDir}/Array/contains.sh"

teardown() {
  unstub_all
}

function Linux::requireUbuntu::failure { #@test
  source() {
    if [[ "$1" != "/etc/os-release" ]]; then
      exit 1
    fi
    echo "Alpine"
  }
  run Linux::requireUbuntu

  assert_failure 1
  assert_output --partial "FATAL   - this script should be executed under Ubuntu or Debian OS"
}

function Linux::requireUbuntu::success { #@test
  source() {
    if [[ "$1" != "/etc/os-release" ]]; then
      exit 1
    fi
    echo "ubuntu"
  }
  run Linux::requireUbuntu

  assert_success
  assert_output ""
}

function Linux::requireUbuntu::success2 { #@test
  source() {
    if [[ "$1" != "/etc/os-release" ]]; then
      exit 1
    fi
    echo "debian"
  }
  run Linux::requireUbuntu

  assert_success
  assert_output ""
}
