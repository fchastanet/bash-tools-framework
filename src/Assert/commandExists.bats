#!/usr/bin/env bash

FRAMEWORK_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
vendorDir="${FRAMEWORK_DIR}/vendor"
srcDir="${FRAMEWORK_DIR}/src"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Assert/commandExists.sh
source "${srcDir}/Assert/commandExists.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

teardown() {
  unstub_all
}

function Assert::commandExists { #@test

  run Assert::commandExists "bash"
  assert_success
  assert_output ""
}

function Assert::commandExistsFalse { #@test
  run Assert::commandExists "invalidCommand"
  assert_failure
  assert_output --partial "ERROR   - invalidCommand is not installed, please install it"
}
