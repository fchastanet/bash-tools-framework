#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Docker/getBuildCacheFromArg.sh
source "${BATS_TEST_DIRNAME}/getBuildCacheFromArg.sh"
# shellcheck source=/src/Filters/toLowerCase.sh
source "${srcDir}/Filters/toLowerCase.sh"

function Docker::getBuildCacheFromArgEmpty { #@test
  run Docker::getBuildCacheFromArg
  assert_output ""
}

function Docker::getBuildCacheFromArg1Tag { #@test
  run Docker::getBuildCacheFromArg "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools"
  assert_output --partial "--cache-from='id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools' "
}

function Docker::getBuildCacheFromArg2Tags { #@test
  run Docker::getBuildCacheFromArg "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "tag2"
  assert_output --partial "--cache-from='id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools' --cache-from='tag2' "
}

function Docker::getBuildCacheFromArg1EmptyTag { #@test
  run Docker::getBuildCacheFromArg ""
  assert_output ""
}

function Docker::getBuildCacheFromArg1EmptyTag2 { #@test
  run Docker::getBuildCacheFromArg "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" ""
  assert_output --partial "--cache-from='id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools' "
}
