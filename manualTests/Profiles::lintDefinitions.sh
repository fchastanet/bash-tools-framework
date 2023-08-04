#!/usr/bin/env bash

# test use to manually test when difficult to debug through bats
srcDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)/src"

# shellcheck source=/src/batsHeaders.sh
source "${srcDir}/batsHeaders.sh"

BATS_TEST_DIRNAME="${srcDir}/Profiles"

#set -x
Profiles::lintDefinitions \
  "${BATS_TEST_DIRNAME}/testsData/lintDefinitions/KO" "plain"
