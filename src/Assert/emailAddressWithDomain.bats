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
# shellcheck source=/src/Assert/emailAddressWithDomain.sh
source "${srcDir}/Assert/emailAddressWithDomain.sh"

function Assert::emailAddressWithDomainEmpty { #@test
  run Assert::emailAddressWithDomain ""
  assert_failure 1
  assert_output ""
}

function Assert::emailAddressWithDomain@ { #@test
  run Assert::emailAddressWithDomain "@"
  assert_failure 1
  assert_output ""
}

function Assert::emailAddressWithDomainMissingPrefix { #@test
  run Assert::emailAddressWithDomain "@domain.com"
  assert_failure 1
  assert_output ""
}

function Assert::emailAddressWithDomainMissingSuffix { #@test
  run Assert::emailAddressWithDomain "prefix@"
  assert_failure 1
  assert_output ""
}

function Assert::emailAddressWithDomainValid { #@test
  run Assert::emailAddressWithDomain "prefix@domain.com"
  assert_success
  assert_output ""
}

function Assert::emailAddressWithDomainValidExpectedDomain { #@test
  run Assert::emailAddressWithDomain "prefix@domain.com" "domain.com"
  assert_success
  assert_output ""
}

function Assert::emailAddressWithDomainValidSecondExpectedDomain { #@test
  run Assert::emailAddressWithDomain "prefix@domain.com" "google.com" "domain.com"
  assert_success
  assert_output ""
}

function Assert::emailAddressWithDomainValidNonExpectedDomain { #@test
  run Assert::emailAddressWithDomain "prefix@domain2.com" "google.com" "domain.com"
  assert_failure 2
  assert_output ""
}
