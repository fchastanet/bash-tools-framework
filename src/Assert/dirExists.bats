#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/dirExists.sh
source "${srcDir}/Assert/dirExists.sh"

teardown() {
  unstub_all
}

function Assert::dirExists { #@test

  run Assert::dirExists "${BATS_TEST_DIRNAME}"
  assert_success
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Check if directory ${BATS_TEST_DIRNAME} exists with user"
}

function Assert::dirExists::False { #@test
  run Assert::dirExists "invalidDir"
  assert_failure
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Check if directory invalidDir exists with user"
  assert_line --index 1 --partial "ERROR   - missing directory invalidDir"
}

function Assert::dirExists::invalidUser { #@test
  run Assert::dirExists "${BATS_TEST_DIRNAME}" "invalidUser" "$(id -gn)"
  assert_failure
  assert_line --index 0 --partial "INFO    - Check if directory ${BATS_TEST_DIRNAME} exists with user"
  assert_line --index 1 --partial "ERROR   - incorrect user ownership on directory ${BATS_TEST_DIRNAME}"
}

function Assert::dirExists::invalidGroup { #@test
  run Assert::dirExists "${BATS_TEST_DIRNAME}" "$(id -un)" "invalidGroup"
  assert_failure
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Check if directory ${BATS_TEST_DIRNAME} exists with user"
  assert_line --index 1 --partial "ERROR   - incorrect group ownership on directory ${BATS_TEST_DIRNAME}"
}
