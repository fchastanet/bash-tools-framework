#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/emailAddress.sh
source "${srcDir}/Assert/emailAddress.sh"

function Assert::emailAddress::Empty { #@test
  run Assert::emailAddress ""
  assert_failure
  assert_output ""
}

function Assert::emailAddress::@ { #@test
  run Assert::emailAddress "@"
  assert_failure
  assert_output ""
}

function Assert::emailAddress::MissingPrefix { #@test
  run Assert::emailAddress "@domain.com"
  assert_failure
  assert_output ""
}

function Assert::emailAddress::MissingSuffix { #@test
  run Assert::emailAddress "prefix@"
  assert_failure
  assert_output ""
}

function Assert::emailAddress::Valid { #@test
  run Assert::emailAddress "prefix@domain.com"
  assert_success
  assert_output ""
}
