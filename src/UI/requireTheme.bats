#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/UI/requireTheme.sh
source "${srcDir}/UI/requireTheme.sh"
# shellcheck source=src/UI/theme.sh
source "${srcDir}/UI/theme.sh"

function UI::requireTheme::noTheme { #@test
  local status="0"
  Assert::tty() {
    return 0
  }
  unset BASH_FRAMEWORK_THEME
  UI::requireTheme >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""

  [[ "${BASH_FRAMEWORK_THEME}" = "default" ]]
  [[ "${__ERROR_COLOR}" = '\e[31m' ]]
}

function UI::requireTheme::defaultTheme { #@test
  local status="0"
  Assert::tty() {
    return 0
  }
  export BASH_FRAMEWORK_THEME="default"
  UI::requireTheme >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""

  [[ "${BASH_FRAMEWORK_THEME}" = "default" ]]
  [[ "${__ERROR_COLOR}" = '\e[31m' ]]
}

function UI::requireTheme::noColorTheme { #@test
  local status="0"
  Assert::tty() {
    return 0
  }
  export BASH_FRAMEWORK_THEME="noColor"
  UI::requireTheme >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""

  [[ "${__ERROR_COLOR}" = "" ]]
  [[ "${BASH_FRAMEWORK_THEME}" = "noColor" ]]
}

function UI::requireTheme::defaultThemeButNoTTY { #@test
  local status="0"
  Assert::tty() {
    return 1
  }
  unset BASH_FRAMEWORK_THEME
  UI::requireTheme >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""

  [[ "${__ERROR_COLOR}" = "" ]]
  [[ "${BASH_FRAMEWORK_THEME}" = "noColor" ]]
}
