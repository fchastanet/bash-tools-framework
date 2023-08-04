#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

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
  assert_output --partial "ERROR   - Build directory invalid 'badBuildDirectory'"
}

function Docker::buildImageInvalidDockerfile { #@test
  run Docker::buildImage "." "Dockerfile" "localImageName" 2>&1
  assert_failure 2
  assert_output --partial "ERROR   - Dockerfile path invalid 'Dockerfile'"
}

function Docker::buildImageInvalidLocalImageName { #@test
  run Docker::buildImage "." "${BATS_TEST_DIRNAME}/testsData/Dockerfile" "" 2>&1
  assert_failure 3
  assert_output --partial "ERROR   - empty localImageName"
}

function Docker::buildImage { #@test
  stub docker \
    "build --build-arg BUILDKIT_INLINE_CACHE=1 -f '${BATS_TEST_DIRNAME}/testsData/Dockerfile' -t 'localImageName' . : echo 'success'"
  run Docker::buildImage "." "${BATS_TEST_DIRNAME}/testsData/Dockerfile" "localImageName" 2>&1
  assert_success
  assert_output "success"
}
