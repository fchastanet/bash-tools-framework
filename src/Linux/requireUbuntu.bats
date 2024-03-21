#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/requireUbuntu.sh
source "${srcDir}/Linux/requireUbuntu.sh"
# shellcheck source=src/Linux/getDistributorId.sh
source "${srcDir}/Linux/getDistributorId.sh"

teardown() {
  unstub_all
}

function Linux::requireUbuntu::failure { #@test
  stub lsb_release '-a : echo "Distributor ID: Alpine"'
  run Linux::requireUbuntu

  assert_failure 1
  assert_output --partial "FATAL - this script should be executed under Ubuntu or Debian OS"
}

function Linux::requireUbuntu::success { #@test
  stub lsb_release '-a : echo "Distributor ID: Ubuntu"'
  run Linux::requireUbuntu

  assert_success
  assert_output ""
}

function Linux::requireUbuntu::success2 { #@test
  stub lsb_release '-a : echo "Distributor ID: Debian"'
  run Linux::requireUbuntu

  assert_success
  assert_output ""
}
