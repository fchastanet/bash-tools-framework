#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/requireExecutedAsRoot.sh
source "${srcDir}/Linux/requireExecutedAsRoot.sh"

function Linux::requireExecutedAsRoot::failure { #@test
  stub id '-u : echo "1000"'

  run Linux::requireExecutedAsRoot

  assert_failure 1
  assert_output --partial "FATAL   - this script should be executed as root"
}

function Linux::requireExecutedAsRoot::success { #@test
  stub id '-u : echo "0"'

  run Linux::requireExecutedAsRoot

  assert_success
  assert_output ""
}
