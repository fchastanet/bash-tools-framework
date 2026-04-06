#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/getCodename.sh
source "${srcDir}/Linux/getCodename.sh"

tearDown() {
  unstub_all
}

function Linux::getCodename::failure { #@test
  stub awk '-F= * /etc/os-release : exit 1'

  run Linux::getCodename

  assert_failure 2
  assert_output ""
}

function Linux::getCodename::success { #@test
  stub awk '-F= * /etc/os-release : echo "focal"'

  run Linux::getCodename

  assert_success
  assert_output "focal"
}
