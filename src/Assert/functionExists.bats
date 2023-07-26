#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src//Assert/functionExists.sh
source "${srcDir}/Assert/functionExists.sh"

function Assert::functionExists::notExists { #@test
  run Assert::functionExists "zfxyuip"
  assert_failure 1
  assert_output ""
}

function Assert::functionExists::builtinCmd { #@test
  run Assert::functionExists "alias"
  assert_failure
  assert_output ""
}

function Assert::functionExists::cmd { #@test
  run Assert::functionExists "grep"
  assert_failure
  assert_output ""
}

function Assert::functionExists::exists { #@test
  myFunction() {
    return 0
  }
  run Assert::functionExists "myFunction"
  assert_success
  assert_output ""
}
