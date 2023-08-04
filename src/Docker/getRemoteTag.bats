#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Docker/getRemoteTag.sh
source "${BATS_TEST_DIRNAME}/getRemoteTag.sh"
# shellcheck source=/src/Filters/toLowerCase.sh
source "${srcDir}/Filters/toLowerCase.sh"

function Docker::getRemoteTag { #@test
  run Docker::getRemoteTag "id.dkr.ecr.eu-west-1.amazonaws.com" "bash-tools" "tag"
  assert_output "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag"
}
