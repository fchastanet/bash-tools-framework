#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/firstNameLastName.sh
source "${srcDir}/Assert/firstNameLastName.sh"

function Assert::firstNameLastName::invalid { #@test
  run Assert::firstNameLastName ""
  assert_failure 1
  assert_output ""
}

function Assert::firstNameLastName::onlyFirstName { #@test
  run Assert::firstNameLastName "A"
  assert_failure 1
  assert_output ""
}

function Assert::firstNameLastName::valid { #@test
  run Assert::firstNameLastName "A B"
  assert_success
  assert_output ""
}

function Assert::firstNameLastName::hyphen { #@test
  run Assert::firstNameLastName "Marie-France Dupont"
  assert_success
  assert_output ""
}

function Assert::firstNameLastName::spaceAtTheEnd { #@test
  run Assert::firstNameLastName "Marie-France Dupont "
  assert_failure 1
  assert_output ""
}

function Assert::firstNameLastName::accent { #@test
  run Assert::firstNameLastName "François hétérogénéité"
  assert_success
  assert_output ""
}
