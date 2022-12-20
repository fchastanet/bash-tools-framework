#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"
srcDir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Docker/getTagCompatibleFromBranch.sh
source "${BATS_TEST_DIRNAME}/getTagCompatibleFromBranch.sh"
# shellcheck source=/src/Filters/toLowerCase.sh
source "${srcDir}/Filters/toLowerCase.sh"

function Docker::getTagCompatibleFromBranch { #@test
  echo "origin/master" | {
    run Docker::getTagCompatibleFromBranch
    assert_output "master"
  }

  echo "origin/feature/My-beautiful-feature" | {
    run Docker::getTagCompatibleFromBranch
    assert_output "feature_my-beautiful-feature"
  }

  echo "origin/feature/My-beautiful-feature" | {
    run Docker::getTagCompatibleFromBranch "#"
    assert_output "feature#my-beautiful-feature"
  }
}
