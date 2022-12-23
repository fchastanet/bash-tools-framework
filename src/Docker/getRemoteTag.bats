#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"
srcDir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Docker/getRemoteTag.sh
source "${BATS_TEST_DIRNAME}/getRemoteTag.sh"
# shellcheck source=/src/Filters/toLowerCase.sh
source "${srcDir}/Filters/toLowerCase.sh"

function Docker::getRemoteTag { #@test
  run Docker::getRemoteTag "id.dkr.ecr.eu-west-1.amazonaws.com" "bash-tools" "tag"
  assert_output "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag"
}
