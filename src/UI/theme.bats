#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/UI/theme.sh
source "${srcDir}/UI/theme.sh"

function UI::theme::defaultTheme { #@test
  local status="0"
  Assert::tty() {
    return 0
  }
  UI::theme >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""

  [[ "${BASH_FRAMEWORK_THEME}" = "default" ]]
  [[ "${__ERROR_COLOR}" = '\e[31m' ]]
}

function UI::theme::defaultThemeButNoTTY { #@test
  local status="0"
  Assert::tty() {
    return 1
  }
  UI::theme >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""

  [[ "${BASH_FRAMEWORK_THEME}" = "noColor" ]]
  [[ "${__ERROR_COLOR}" = '' ]]
}

function UI::theme::noColorTheme { #@test
  local status="0"
  Assert::tty() {
    return 0
  }
  UI::theme "noColor" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""

  [[ "${BASH_FRAMEWORK_THEME}" = "noColor" ]]
  [[ "${__ERROR_COLOR}" = '' ]]
}
