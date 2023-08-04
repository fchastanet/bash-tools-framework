#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/validPath.sh
source "${BATS_TEST_DIRNAME}/validPath.sh"

function Assert::validPath::invalidAccents { #@test
  run Assert::validPath "/bash/invalidé"
  assert_failure
  assert_output ""
}

function Assert::validPath::invalidAntiSlash { #@test
  run Assert::validPath $"/invalid\Path"
  assert_failure
  assert_output ""
}

function Assert::validPath::invalid@ { #@test
  run Assert::validPath "/invalid@"
  assert_failure
  assert_output ""
}

function Assert::validPath::invalidSpaces { #@test
  run Assert::validPath "/invalid Path"
  assert_failure
  assert_output ""
}

function Assert::validPath::empty { #@test
  run Assert::validPath ""
  assert_failure
  assert_output ""
}

function Assert::validPath::invalidLeadingDash { #@test
  run Assert::validPath "-directory/file"
  assert_failure
  assert_output ""
}

function Assert::validPath::invalidInsideDash { #@test
  run Assert::validPath "/root/-directory/file"
  assert_failure
  assert_output ""
}

function Assert::validPath::invalidRelativePath { #@test
  run Assert::validPath "../relative/dir"
  assert_failure
  assert_output ""
}

function Assert::validPath::invalidParentDir { #@test
  run Assert::validPath ".."
  assert_failure
  assert_output ""
}

function Assert::validPath::invalidCurrentDir { #@test
  run Assert::validPath "."
  assert_failure
  assert_output ""
}

function Assert::validPath::invalidSubCurrentDir { #@test
  run Assert::validPath "./relative"
  assert_failure
  assert_output ""
}

function Assert::validPath::invalidInsideRelativePath { #@test
  run Assert::validPath "/root/../relative/dir"
  assert_failure
  assert_output ""
}

function Assert::validPath::validNonPosixPath { #@test
  run Assert::validPath "/tmp/bats-run-meYafj/bin/awkLint"
  assert_success
  assert_output ""
}

function Assert::validPath::valid { #@test
  run Assert::validPath "/valid/Path"
  assert_success
  assert_output ""
}

function Assert::validPath::validReal { #@test
  run Assert::validPath "/home/wsl/fchastanet/bash-dev-env/vendor/bash-tools-framework/src/Filters/testsData/commentLines.txt"
  assert_success
  assert_output ""
}
