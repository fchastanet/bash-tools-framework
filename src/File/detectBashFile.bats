#!/usr/bin/env bash

rootDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
vendorDir="${rootDir}/vendor"
srcDir="${rootDir}/src"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/File/detectBashFile.sh
source "${srcDir}/File/detectBashFile.sh"

function File::detectBashFile::shFile { #@test
  run File::detectBashFile "${srcDir}/File/detectBashFile.sh"
  assert_success
  assert_output ""
}

function File::detectBashFile::alternateShebang { #@test
  run File::detectBashFile "${BATS_TEST_DIRNAME}/testsData/alternateShebang.sh"
  assert_success
  assert_output ""
}

function File::detectBashFile::markdown { #@test
  run File::detectBashFile "${rootDir}/README.md"
  assert_failure 1
  assert_output ""
}
