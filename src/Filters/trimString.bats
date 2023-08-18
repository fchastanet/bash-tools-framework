#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/trimString.sh
source "${BATS_TEST_DIRNAME}/trimString.sh"

function Filters::trimString::stdin { #@test
  echo -e "   \tTEST1 \t TEST2 \t" | {
    run Filters::trimString
    assert_success
    assert_output "$(echo -e "TEST1 \t TEST2")"
  }
}

function Filters::trimString::stdinEmpty { #@test
  echo -e "" | {
    run Filters::trimString
    assert_success
    assert_output ""
  }
}

function Filters::trimString::stdinOnlySpaces { #@test
  echo -e "  \t  \t   \t " | {
    run Filters::trimString
    assert_success
    assert_output ""
  }
}

function Filters::trimString::file { #@test
  echo -e "   \tTEST1 \t TEST2 \t" >"${BATS_TEST_TMPDIR}/file"
  run Filters::trimString "${BATS_TEST_TMPDIR}/file"
  assert_success
  assert_output "$(echo -e "TEST1 \t TEST2")"
}
