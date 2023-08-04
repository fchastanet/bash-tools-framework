#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Docker/tagImage.sh
source "${BATS_TEST_DIRNAME}/tagImage.sh"
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

function Docker::tagImageWithoutTags { #@test
  run Docker::tagImage "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "image:latest" 2>&1
  assert_failure
  assert_output --partial "ERROR   - At least one tag should be provided"
}

function Docker::tagImageWith1Tag { #@test
  stub docker \
    'tag "image:latest" "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag1" : true'
  run Docker::tagImage "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "image:latest" "tag1"
  assert_success
}

function Docker::tagImageWith2Tags { #@test
  stub docker \
    'tag "image:latest" "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag1" : true' \
    'tag "image:latest" "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag2" : true'
  run Docker::tagImage \
    "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "image:latest" "tag1" "tag2"
  assert_success
}
