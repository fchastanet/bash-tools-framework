#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/ldapLogin.sh
source "${srcDir}/Assert/ldapLogin.sh"

function Assert::ldapLogin::invalid { #@test
  run Assert::ldapLogin ""
  assert_failure 1
  assert_output ""
}

function Assert::ldapLogin::noAccent { #@test
  run Assert::ldapLogin "frégate"
  assert_failure 1
  assert_output ""
}

function Assert::ldapLogin::noUppercase { #@test
  run Assert::ldapLogin "Antelope"
  assert_failure 1
  assert_output ""
}

function Assert::ldapLogin::noSpace { #@test
  run Assert::ldapLogin "Francois Software"
  assert_failure 1
  assert_output ""
}

function Assert::ldapLogin::valid { #@test
  run Assert::ldapLogin "fchastanet"
  assert_success
  assert_output ""
}
