#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/uniqUnsorted.sh
source "${BATS_TEST_DIRNAME}/uniqUnsorted.sh"

function Filters::uniqUnsorted::stdin { #@test
  (
    echo "a"
    echo "b"
    echo "a"
  ) | {
    run Filters::uniqUnsorted
    assert_lines_count 2
    assert_line --index 0 "a"
    assert_line --index 1 "b"
  }
}

function Filters::uniqUnsorted::fileArg { #@test
  (
    echo "a"
    echo "b"
    echo "a"
  ) >"${BATS_TEST_TMPDIR}/tmpFile"
  run Filters::uniqUnsorted "${BATS_TEST_TMPDIR}/tmpFile"
  assert_lines_count 2
  assert_line --index 0 "a"
  assert_line --index 1 "b"
}

function Filters::uniqUnsorted::realExample { #@test
  (
    echo '# @require Linux::requireSudoCommand'
    echo '# @require Linux::requireUbuntu'
    echo '# @require Log::requireLoad'
    echo '# @require Linux::requireSudoCommand'
    echo '# @require Env::requireLoad'
    echo '# @require Log::requireLoad'
    echo '# @require Linux::requireUbuntu'
  ) >"${BATS_TEST_TMPDIR}/tmpFile"
  run Filters::uniqUnsorted "${BATS_TEST_TMPDIR}/tmpFile"
  assert_lines_count 4
  assert_line --index 0 "# @require Linux::requireSudoCommand"
  assert_line --index 1 "# @require Linux::requireUbuntu"
  assert_line --index 2 "# @require Log::requireLoad"
  assert_line --index 3 "# @require Env::requireLoad"
}
