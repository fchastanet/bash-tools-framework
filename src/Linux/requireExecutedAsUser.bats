#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/requireExecutedAsUser.sh
source "${srcDir}/Linux/requireExecutedAsUser.sh"

function Linux::requireExecutedAsUser::failure { #@test
  stub id '-u : echo "0"'

  run Linux::requireExecutedAsUser

  assert_failure 1
  assert_output --partial "FATAL   - this script should be executed as normal user"
}

function Linux::requireExecutedAsUser::success { #@test
  stub id '-u : echo "1000"'

  run Linux::requireExecutedAsUser

  assert_success
  assert_output ""
}
