#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/removeAnsiCodes.sh
source "${BATS_TEST_DIRNAME}/removeAnsiCodes.sh"

function Filters::removeAnsiCodes::stdin { #@test
  # cspell:disable
  echo -e "\e[31mremove\e[32mAnsi\e[1;30mCodes injected\e[7;49;33m" | {
    run Filters::removeAnsiCodes
    assert_output "removeAnsiCodes injected"
  }
  # cspell:enable
}

function Filters::removeAnsiCodes::fromFile { #@test
  # cspell:disable
  echo -e "\e[31mremove\e[32mAnsi\e[1;30mCodes injected\e[7;49;33m" >"${BATS_TEST_TMPDIR}/test"
  run Filters::removeAnsiCodes "${BATS_TEST_TMPDIR}/test"
  assert_output "removeAnsiCodes injected"
  # cspell:enable
}
