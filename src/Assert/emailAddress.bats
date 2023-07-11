#!/usr/bin/env bash

FRAMEWORK_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
vendorDir="${FRAMEWORK_DIR}/vendor"
srcDir="${FRAMEWORK_DIR}/src"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Assert/emailAddress.sh
source "${srcDir}/Assert/emailAddress.sh"

function Assert::emailAddressEmpty { #@test
  run Assert::emailAddress ""
  assert_failure
  assert_output ""
}

function Assert::emailAddress@ { #@test
  run Assert::emailAddress "@"
  assert_failure
  assert_output ""
}

function Assert::emailAddressMissingPrefix { #@test
  run Assert::emailAddress "@domain.com"
  assert_failure
  assert_output ""
}

function Assert::emailAddressMissingSuffix { #@test
  run Assert::emailAddress "prefix@"
  assert_failure
  assert_output ""
}

function Assert::emailAddressValid { #@test
  run Assert::emailAddress "prefix@domain.com"
  assert_success
  assert_output ""
}
