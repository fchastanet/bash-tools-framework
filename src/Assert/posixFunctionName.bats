#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Assert/posixFunctionName.sh
source "${BATS_TEST_DIRNAME}/posixFunctionName.sh"

function Assert::posixFunctionName::noMatch { #@test
  run Assert::posixFunctionName "Log::fatal"
  assert_failure
  assert_output ""
}

function Assert::posixFunctionName::noMatch2 { #@test
  run Assert::posixFunctionName "Log:fatal"
  assert_failure
  assert_output ""
}

function Assert::posixFunctionName::noMatchComments1 { #@test
  run Assert::posixFunctionName "# logFatal"
  assert_failure
  assert_output ""
}

function Assert::posixFunctionName::noMatchSpaceBefore { #@test
  run Assert::posixFunctionName "  \t logFatal"
  assert_failure
  assert_output ""
}

function Assert::posixFunctionName::noMatchSpaceAfter { #@test
  run Assert::posixFunctionName "logFatal  \t "
  assert_failure
  assert_output ""
}

function Assert::posixFunctionName::noMatchSpaceInside { #@test
  run Assert::posixFunctionName "Log  \t fatal"
  assert_failure
  assert_output ""
}

function Assert::posixFunctionName::noMatchAccents { #@test
  run Assert::posixFunctionName "LogFatalFrançois"
  assert_failure
  assert_output ""
}

function Assert::posixFunctionName::noMatchDash { #@test
  run Assert::posixFunctionName "Log-Fatal"
  assert_failure
  assert_output ""
}

function Assert::posixFunctionName::validSimple { #@test
  run Assert::posixFunctionName "logFatal"
  assert_success
  assert_output ""
}

function Assert::posixFunctionName::validUnderscore { #@test
  run Assert::posixFunctionName "log_fatal"
  assert_success
  assert_output ""
}
