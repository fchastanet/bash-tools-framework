#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/requireUbuntu.sh
source "${srcDir}/Linux/requireUbuntu.sh"
# shellcheck source=src/Array/contains.sh
source "${srcDir}/Array/contains.sh"

function Linux::requireUbuntu::failure { #@test
  Linux::getDistributorId() {
    exit 1
  }
  run Linux::requireUbuntu

  assert_failure 1
  assert_output --partial "FATAL   - this script should be executed under Ubuntu or Debian OS"
}

function Linux::requireUbuntu::success { #@test
  Linux::getDistributorId() {
    echo "ubuntu"
  }
  run Linux::requireUbuntu

  assert_success
  assert_output ""
}

function Linux::requireUbuntu::success2 { #@test
  Linux::getDistributorId() {
    echo "debian"
  }
  run Linux::requireUbuntu

  assert_success
  assert_output ""
}
