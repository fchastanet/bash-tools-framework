#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/validPosixPath.sh
source "${BATS_TEST_DIRNAME}/validPosixPath.sh"

function Assert::validPosixPath::invalidAccents { #@test
  run Assert::validPosixPath "/bash/invalidé"
  assert_failure
  assert_output --partial "pathchk: nonportable character"
}

function Assert::validPosixPath::invalidAntiSlash { #@test
  run Assert::validPosixPath $"invalid\Path"
  assert_failure
  assert_output --partial 'pathchk: nonportable character'
  assert_output --partial $'\\'
}

function Assert::validPosixPath::invalid@ { #@test
  run Assert::validPosixPath "invalid@"
  assert_failure
  assert_output --partial "pathchk: nonportable character"
  assert_output --partial "@"
}

function Assert::validPosixPath::invalidSpaces { #@test
  run Assert::validPosixPath "/invalid Path"
  assert_failure
  assert_output --partial "pathchk: nonportable character"
}

function Assert::validPosixPath::invalidTooLong { #@test
  run Assert::validPosixPath "/tmp/bats-run-meYafj/bin/awkLint"
  assert_failure
  assert_output --partial "pathchk: limit 14 exceeded by length 15 of file name component"
}

function Assert::validPosixPath::empty { #@test
  run Assert::validPosixPath ""
  assert_failure
  assert_output --partial "pathchk: empty file name"
}

function Assert::validPosixPath::invalidLeadingDash { #@test
  run Assert::validPosixPath "-directory/file"
  assert_failure
  assert_line --index 0 --partial "pathchk: invalid option -- 'd'"
}

function Assert::validPosixPath::invalidInsideDash { #@test
  run Assert::validPosixPath "/root/-directory/file"
  assert_failure
  assert_output --partial "pathchk: leading"
  assert_output --partial "in a component of file name"
}

function Assert::validPosixPath::invalidRelativePath { #@test
  run Assert::validPosixPath "../relative/dir"
  assert_failure
  assert_output ""
}

function Assert::validPosixPath::invalidInsideRelativePath { #@test
  run Assert::validPosixPath "/root/../relative/dir"
  assert_failure
  assert_output ""
}

function Assert::validPosixPath::valid { #@test
  run Assert::validPosixPath "/valid/Path"
  assert_success
  assert_output ""
}
