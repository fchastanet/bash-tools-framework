#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"
srcDir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Docker/buildImage.sh
source "${BATS_TEST_DIRNAME}/buildImage.sh"
# shellcheck source=/src/Log/displayInfo.sh
source "${srcDir}/Log/displayInfo.sh"
# shellcheck source=/src/Log/displayError.sh
source "${srcDir}/Log/displayError.sh"
# shellcheck source=/src/Log/logInfo.sh
source "${srcDir}/Log/logInfo.sh"
# shellcheck source=/src/Log/logError.sh
source "${srcDir}/Log/logError.sh"
# shellcheck source=/src/Log/logMessage.sh
source "${srcDir}/Log/logMessage.sh"

teardown() {
  unstub_all
}

function Docker::buildImageInvalidBuildDirectory { #@test
  run Docker::buildImage "badBuildDirectory" "${BATS_TEST_DIRNAME}/testsData/Dockerfile" "localImageName" 2>&1
  assert_failure 1
  assert_output "ERROR   - Build directory invalid 'badBuildDirectory'"
}

function Docker::buildImageInvalidDockerfile { #@test
  run Docker::buildImage "." "Dockerfile" "localImageName" 2>&1
  assert_failure 2
  assert_output "ERROR   - Dockerfile path invalid 'Dockerfile'"
}

function Docker::buildImageInvalidLocalImageName { #@test
  run Docker::buildImage "." "${BATS_TEST_DIRNAME}/testsData/Dockerfile" "" 2>&1
  assert_failure 3
  assert_output "ERROR   - empty localImageName"
}

function Docker::buildImage { #@test
  stub docker \
    "build --build-arg BUILDKIT_INLINE_CACHE=1 -f '${BATS_TEST_DIRNAME}/testsData/Dockerfile' -t 'localImageName' . : echo 'success'"
  run Docker::buildImage "." "${BATS_TEST_DIRNAME}/testsData/Dockerfile" "localImageName" 2>&1
  assert_success
  assert_output "success"
}
