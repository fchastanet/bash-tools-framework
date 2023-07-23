#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Docker/pullImage.sh
source "${BATS_TEST_DIRNAME}/pullImage.sh"
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

function Docker::pullImageWithoutTags { #@test
  run Docker::pullImage "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" 2>&1
  assert_failure
  assert_output --partial "ERROR   - At least one tag should be provided"
}

function Docker::pullImageWith1Tag { #@test
  stub docker \
    "pull 'id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag1' : cat '${BATS_TEST_DIRNAME}/testsData/pullImage.txt'"
  run Docker::pullImage "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "tag1"
  assert_success
  assert_line --index 0 --partial "INFO    - docker pull id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag1"
  assert_line --index 1 "27cb6e6ccef575a4698b66f5de06c7ecd61589132d5a91d098f7f3f9285415a9"
}

function Docker::pullImageWith2Tags { #@test
  stub docker \
    "pull 'id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag1' : exit 1" \
    "pull 'id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag2' : cat '${BATS_TEST_DIRNAME}/testsData/pullImage.txt'"
  run Docker::pullImage \
    "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "tag1" "tag2" 2>&1
  assert_success
  assert_line --index 0 --partial "INFO    - docker pull id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag1"
  assert_line --index 1 --partial "INFO    - docker pull id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag2"
  assert_line --index 2 "27cb6e6ccef575a4698b66f5de06c7ecd61589132d5a91d098f7f3f9285415a9"
}

function Docker::pullImageWith2TagsFailure { #@test
  stub docker \
    "pull 'id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag1' : exit 1" \
    "pull 'id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag2' : exit 1"
  run Docker::pullImage \
    "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "tag1" "tag2" 2>&1
  assert_failure
  assert_line --index 0 --partial "INFO    - docker pull id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag1"
  assert_line --index 1 --partial "INFO    - docker pull id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag2"
  assert_line --index 2 --partial "ERROR   - No image pulled"
}
