#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Docker/buildPushDockerImage.sh
source "${BATS_TEST_DIRNAME}/buildPushDockerImage.sh"
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

function Docker::buildPushDockerImage::successTraceOn { #@test
  stub docker \
    'pull scrasnups/build:bash-tools-vendor-5.1 : echo "pull"' \
    "build -f ${FRAMEWORK_ROOT_DIR}/.docker/Dockerfile.vendor --cache-from scrasnups/build:bash-tools-vendor-5.1 --build-arg BUILDKIT_INLINE_CACHE=1 --build-arg argBashVersion=5.1 --build-arg BASH_IMAGE=base -t build:bash-tools-vendor-5.1 -t scrasnups/build:bash-tools-vendor-5.1 ${FRAMEWORK_ROOT_DIR}/.docker : echo 'build'" \
    'run --rm build:bash-tools-vendor-5.1 bash --version : echo version'
  run Docker::buildPushDockerImage "vendor" "5.1" "base" "0" "1" 2>&1

  assert_success
  assert_lines_count 9
  assert_line --index 0 --partial "INFO    - Pull image scrasnups/build:bash-tools-vendor-5.1"
  assert_line --index 3 --partial "INFO    - Build image scrasnups/build:bash-tools-vendor-5.1"
  assert_line --index 7 --partial "INFO    - Image scrasnups/build:bash-tools-vendor-5.1 - bash version check"
}

function Docker::buildPushDockerImage::successTraceOff { #@test
  stub docker \
    'pull scrasnups/build:bash-tools-vendor-5.1 : echo "pull"' \
    "build -f ${FRAMEWORK_ROOT_DIR}/.docker/Dockerfile.vendor --cache-from scrasnups/build:bash-tools-vendor-5.1 --build-arg BUILDKIT_INLINE_CACHE=1 --build-arg argBashVersion=5.1 --build-arg BASH_IMAGE=base -t build:bash-tools-vendor-5.1 -t scrasnups/build:bash-tools-vendor-5.1 ${FRAMEWORK_ROOT_DIR}/.docker : echo 'build'" \
    'run --rm build:bash-tools-vendor-5.1 bash --version : echo version'
  run Docker::buildPushDockerImage "vendor" "5.1" "base" "0" "0" 2>&1

  assert_success
  assert_lines_count 6
  assert_line --index 0 --partial "INFO    - Pull image scrasnups/build:bash-tools-vendor-5.1"
  assert_line --index 2 --partial "INFO    - Build image scrasnups/build:bash-tools-vendor-5.1"
  assert_line --index 4 --partial "INFO    - Image scrasnups/build:bash-tools-vendor-5.1 - bash version check"
}

function Docker::buildPushDockerImage::successTraceOnPush { #@test
  stub docker \
    'pull scrasnups/build:bash-tools-vendor-5.1 : echo "pull"' \
    "build -f ${FRAMEWORK_ROOT_DIR}/.docker/Dockerfile.vendor --cache-from scrasnups/build:bash-tools-vendor-5.1 --build-arg BUILDKIT_INLINE_CACHE=1 --build-arg argBashVersion=5.1 --build-arg BASH_IMAGE=base -t build:bash-tools-vendor-5.1 -t scrasnups/build:bash-tools-vendor-5.1 ${FRAMEWORK_ROOT_DIR}/.docker : echo 'build'" \
    'run --rm build:bash-tools-vendor-5.1 bash --version : echo version' \
    'push scrasnups/build:bash-tools-vendor-5.1 : echo "push"'
  run Docker::buildPushDockerImage "vendor" "5.1" "base" "1" "1" 2>&1

  assert_success
  assert_lines_count 12
  assert_line --index 0 --partial "INFO    - Pull image scrasnups/build:bash-tools-vendor-5.1"
  assert_line --index 3 --partial "INFO    - Build image scrasnups/build:bash-tools-vendor-5.1"
  assert_line --index 7 --partial "INFO    - Image scrasnups/build:bash-tools-vendor-5.1 - bash version check"
  assert_line --index 9 --partial "INFO    - Push image scrasnups/build:bash-tools-vendor-5.1"
}

function Docker::buildPushDockerImage::successTraceOffPush { #@test
  stub docker \
    'pull scrasnups/build:bash-tools-vendor-5.1 : echo "pull"' \
    "build -f ${FRAMEWORK_ROOT_DIR}/.docker/Dockerfile.vendor --cache-from scrasnups/build:bash-tools-vendor-5.1 --build-arg BUILDKIT_INLINE_CACHE=1 --build-arg argBashVersion=5.1 --build-arg BASH_IMAGE=base -t build:bash-tools-vendor-5.1 -t scrasnups/build:bash-tools-vendor-5.1 ${FRAMEWORK_ROOT_DIR}/.docker : echo 'build'" \
    'run --rm build:bash-tools-vendor-5.1 bash --version : echo version' \
    'push scrasnups/build:bash-tools-vendor-5.1 : echo "push"'
  run Docker::buildPushDockerImage "vendor" "5.1" "base" "1" "0" 2>&1

  assert_success
  assert_lines_count 8
  assert_line --index 0 --partial "INFO    - Pull image scrasnups/build:bash-tools-vendor-5.1"
  assert_line --index 2 --partial "INFO    - Build image scrasnups/build:bash-tools-vendor-5.1"
  assert_line --index 4 --partial "INFO    - Image scrasnups/build:bash-tools-vendor-5.1 - bash version check"
  assert_line --index 6 --partial "INFO    - Push image scrasnups/build:bash-tools-vendor-5.1"
}
