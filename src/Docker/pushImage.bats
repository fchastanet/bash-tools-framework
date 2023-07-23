#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Docker/pushImage.sh
source "${BATS_TEST_DIRNAME}/pushImage.sh"
# shellcheck source=/src/Log/displayError.sh
source "${srcDir}/Log/displayError.sh"
# shellcheck source=/src/Log/logError.sh
source "${srcDir}/Log/logError.sh"
# shellcheck source=/src/Log/logMessage.sh
source "${srcDir}/Log/logMessage.sh"
# shellcheck source=/src/Filters/toLowerCase.sh
source "${srcDir}/Filters/toLowerCase.sh"

teardown() {
  unstub_all
}

function Docker::pushImageWithoutTags { #@test
  run Docker::pushImage "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" 2>&1
  assert_failure
  assert_output --partial "ERROR   - At least one tag should be provided"
}

function Docker::pushImageWith1Tag { #@test
  stub docker \
    'push "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag1" : true'
  run Docker::pushImage "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "tag1"
  assert_success
}

function Docker::pushImageWith2Tags { #@test
  stub docker \
    'push "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag1" : true' \
    'push "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag2" : true'
  run Docker::pushImage \
    "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "tag1" "tag2"
  assert_success
}
